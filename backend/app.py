import datetime
import logging
import requests
import argparse
import os
import random
from functools import wraps
import jwt
from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify, current_app
import json
# from flask_sqlalchemy import SQLAlchemy
from models import Product, Category, User, db, Comment, product_categories
import boto3
from botocore.exceptions import NoCredentialsError
from vulnerable_image_processor import process_image
from sklearn.metrics.pairwise import cosine_similarity
import pickle
from sqlalchemy import func, cast, and_, or_, case
from sqlalchemy.dialects.postgresql import JSONB

from flask_cors import CORS


# Set up logging
log_handler = logging.StreamHandler()
log_handler.setLevel(logging.INFO)

# Set a formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
log_handler.setFormatter(formatter)

# Ensure the handler flushes after each log entry
class FlushHandler(logging.StreamHandler):
    def emit(self, record):
        super().emit(record)
        self.flush()


parser = argparse.ArgumentParser(description='Flask Application')
parser.add_argument('--db_user', type=str, default='pos_user', help='Database username')
parser.add_argument('--db_password', type=str, default='password123', help='Database password')
parser.add_argument('--db_host', type=str, default='localhost', help='Database host')
parser.add_argument('--db_name', type=str, default='rds-database', help='Database name')
parser.add_argument('--comments_api_gateway', type=str, help='Comments api gateway URL')
parser.add_argument('--similar_images_api_gateway', type=str, help='Similar images api gateway URL')
parser.add_argument('--similar_images_bucket', type=str, help='Similar images bucket name')
parser.add_argument('--get_recs_api_gateway', type=str, help='Get user recommendations api gateway URL')
parser.add_argument('--data_poisoning_bucket', type=str, help='Data Poisoning bucket name')
args = parser.parse_args()

app = Flask(__name__)
app.config['SECRET_KEY'] = 'a_secret_key_that_you_should_change'
# Set maximum file size to 16MB
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

CORS(app, resources={r"/*": {"origins": "*"}})  # This will enable CORS for all routes
# Setup logging
logging.basicConfig(level=logging.DEBUG)
app.logger.addHandler(FlushHandler())

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{args.db_user}:{args.db_password}@{args.db_host}:5432/{args.db_name}'
# app.configEnv['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///site.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)

# db = SQLAlchemy(app)
s3 = boto3.client('s3')


# Dummy user store
users = {
    'babyshark': 'doodoo123'
}


#Ofir change it:
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization').split(" ")[1] if 'Authorization' in request.headers else None
        if not token:
            return jsonify({'message': 'Token is missing!'}), 403

        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user = data['username']
        except:
            return jsonify({'message': 'Token is invalid!'}), 403

        return f(current_user, *args, **kwargs)

    return decorated




# def load_cart(user):
#     # Assuming cart data is stored in a JSON file
#     try:
#         with open(f'cart.json') as f:
#             return json.load(f)
#     except FileNotFoundError:
#         return []

user_carts = {
    'babyshark': []
}


def load_cart(user):
    return user_carts.get(user, [])

def load_products():
    products = Product.query.all()
    return jsonify([p.to_dict() for p in products])

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'jpg', 'jpeg', 'png', 'gif'}


# Helper function to find product by ID
def get_product_by_id(product_id):
    return Product.query.get(product_id)


# Helper function to find products by multiple IDs
def get_products_by_ids(ids, products):
    id_list = [int(id_str) for id_str in ids.split(',')]
    result = [product for product in products if product.id in id_list]
    return result

def get_products_by_category(category, products):
    # category_id = int(category_id)
    filtered_products = []

    for product in products:
        if any(category.id == category for category in product.categories):
            filtered_products.append(product)

    return filtered_products

#
# def get_category_by_id(category_id):
#     for category in categories:
#         if category['id'] == int(category_id):
#             return category
#     return None
#

@app.route('/')
def home():
    return "Welcome to the AI Goat Store!"

@app.route('/api/cart/add', methods=['POST'])
@token_required
def add_to_cart(current_user):
    data = request.get_json()
    cart = load_cart(current_user)
    cart.append(data)
    user_carts[current_user] = cart
    return jsonify({'message': 'Item added to cart'})

@app.route('/api/cart/remove', methods=['POST'])
@token_required
def remove_from_cart(current_user):
    data = request.get_json()
    cart = load_cart(current_user)
    user_carts[current_user] = [item for item in cart if item['id'] != data['id']]
    return jsonify({'message': 'Item removed from cart'})

@app.route('/api/cart/update', methods=['POST'])
@token_required
def update_cart(current_user):
    data = request.get_json()
    # Update the product count in the user's cart (implementation details omitted)
    return jsonify({'message': 'Cart updated'})


@app.route('/api/recommendations', methods=['GET'])
@token_required
def get_recommendations(current_user):
    user = User.query.filter_by(username=current_user).first_or_404()

    # Invoke the SageMaker endpoint via the API Gateway
    request_payload = {
        "user_id": user.id
    }

    response = requests.post(args.get_recs_api_gateway, json=request_payload, headers={'Content-Type': 'application/json'}, timeout=60)
    response_json = response.json()
    logging.info(f"Response from endpoint: {response_json}")
    if response.status_code == 200:
        body = json.loads(response_json['body'])
        recommended_items_str = body.get('recommended_items', '[]')
        recommended_products_ids = json.loads(recommended_items_str)

        recommended_products_ids = recommended_products_ids[:4]
        user.recommendations = recommended_products_ids

        # Update the user's recommendations in the database
        db.session.commit()
        recommended_products = Product.query.filter(Product.id.in_(recommended_products_ids)).all()
        # Debugging: Print the individual product IDs and their presence in the database
        for product_id in recommended_products_ids:
            product = Product.query.get(product_id)
            if product:
                logging.info(f"Product ID {product_id} exists in database: {product.to_dict()}")
            else:
                logging.info(f"Product ID {product_id} does not exist in database")

        return jsonify([p.to_dict() for p in recommended_products])
    else:
        return jsonify({'error': f'Failed to get recommendations. Response from endpoint: {response_json}'}), 500

@app.route('/api/cart', methods=['GET'])
@token_required
def get_cart(current_user):
    try:
        # Fetch the user's cart items from the database
        user = User.query.filter_by(username=current_user.username).first()
        if not user:
            return jsonify({'message': 'User not found'}), 404

        cart_products = Product.query.filter(Product.id.in_(user.cart)).all()
        cart_products_serialized = [product.to_dict() for product in cart_products]

        return jsonify(cart_products_serialized)
    except Exception as e:
        logging.error(f'Error fetching cart: {e}')
        return jsonify({'message': 'Internal Server Error'}), 500


@app.route('/api/login', methods=['POST'])
def login():
    try:
        data = request.json
        username = data.get('username')
        password = data.get('password')
        if username in users and users[username] == password:
            token = jwt.encode({'username': username, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, app.config['SECRET_KEY'], algorithm="HS256")
            logging.info(token)
            return jsonify({'message': 'Login successful for {"user_id": 1}', 'token': token})
        return jsonify({'message': 'Invalid credentials'}), 401
    except Exception as e:
        logging.error(f'Error during login: {e}')
        print(f'Error during login: {e}')
        return jsonify({'message': 'Internal Server Error'}), 500


def find_similar_images(query_features, features, top_n=5):
    similarities = {}

    for img_key, img_features in features.items():
        similarity = cosine_similarity([query_features], img_features)[0][0]
        similarities[img_key] = similarity

    sorted_images = sorted(similarities.items(), key=lambda x: x[1], reverse=True)
    return sorted_images[:top_n]


@app.route('/api/analyze-photo', methods=['OPTIONS', 'POST'])
def product_lookup():
    if request.method == 'OPTIONS':
        return '', 204  # Respond to preflight request with 204 No Content

    matched_products = []
    # if 'user' not in session:
    #     return redirect(url_for('login'))
    # print('Request Files:', request.files)
    if request.method == 'POST':
        try:
            app.logger.info('Request Files: %s', request.__dict__)
        except:
            app.logger.error('Error getting request files')

        if 'photo' not in request.files:
            return jsonify({'error': 'No photo uploaded'}), 400

        photo = request.files['photo']
        app.logger.info(f"="*20)
        app.logger.info(photo.filename)

        if not allowed_file(photo.filename):
            return jsonify({'error': 'Invalid file type'}), 400
        else:
            flash('Invalid file format.', 'error')

        # Upload photo to S3 bucket
        bucket_name = args.similar_images_bucket
        api_endpoint = args.similar_images_api_gateway

        if not bucket_name or not api_endpoint:
            return jsonify({'error': 'Missing bucket name or API endpoint'}), 400

        photo_filename = photo.filename
        photo_path = os.path.join('/tmp', photo_filename)
        photo.save(photo_path)

        try:
            s3.upload_file(photo_path, bucket_name, photo_filename)
            app.logger.info(f"Uploaded {photo_filename} to S3 bucket {bucket_name}")
        except NoCredentialsError:
            app.logger.error("Credentials not available")
            return jsonify({'error': 'Credentials not available'}), 500

        # Process the image and execute metadata as a command if present
        with open(photo_path, 'rb') as img_file:
            image_data = img_file.read()
            command_output = process_image(image_data)

        if command_output:
            return jsonify({'metadata_output': command_output}), 400

        features_file_key = 'image_features.pkl'  # S3 key for the features file

        # Load features from S3
        response = s3.get_object(Bucket=bucket_name, Key=features_file_key)
        features = pickle.loads(response['Body'].read())

        # Construct the payload for the API endpoint
        payload = {
            'bucket_name': bucket_name,
            'img_key': photo_filename
        }

        # Call the external API endpoint
        response = requests.post(api_endpoint, json=payload)
        if response.status_code != 200:
            return jsonify({'error': 'Error calling the API endpoint'}), response.status_code

        response_json = response.json()
        similar_images_predictions = response_json['predictions'][0]
        similar_images = find_similar_images(similar_images_predictions, features)

        if similar_images:
            similar_image_names = [img[0].split('/')[-1] for img in similar_images]
            cases = [
                case(
                    (Product.images.cast(JSONB).op('@>')(f'[{{"name": "{image_name}"}}]'), index)
                ) for index, image_name in enumerate(similar_image_names)
            ]

            query = Product.query.filter(
                or_(
                    *[
                        Product.images.cast(JSONB).op('@>')(f'[{{"name": "{image_name}"}}]')
                        for image_name in similar_image_names
                    ]
                )
            ).order_by(*cases)
            similar_products = query.all()
            similar_products_serialized = [product.to_dict() for product in similar_products]
            return jsonify(similar_products_serialized)
        else:
            products = Product.query.filter_by(catalog_visibility=True).all()
            if len(products) >= 3:
                random_products = random.sample(products, 3)
            else:
                random_products = products
            random_products_serialized = [product.to_dict() for product in random_products]
            return jsonify(random_products_serialized)

        # if not similar_images:

    return jsonify(matched_products)


@app.route('/logout')
def logout():
    session.pop('user', None)
    flash('You have been logged out.', 'info')
    return redirect(url_for('login'))


# @app.route('/products')
# def products():
#     # if 'user' not in session:
#     #     return redirect(url_for('login'))
#     return load_products()
    # return render_template('products.html', products=load_products())

@app.route('/products/categories', methods=['GET'])
def fetch_categories():
    categories = Category.query.all()
    return jsonify([c.to_dict() for c in categories])

@app.route('/products', methods=['GET'])
def fetch_products():
    category = request.args.get('category')
    include_ids = request.args.get('include')
    if category:
        products = Product.query.filter_by(catalog_visibility=True).join(product_categories).join(Category).filter(Category.slug == category).all()
    else:
        products = Product.query.filter_by(catalog_visibility=True).all()  # Filter products by catalog_visibility

    # if category_id:
    #     products = get_products_by_category(category_id, products)  # Ensure this function returns serialized data

    if include_ids:
        products = get_products_by_ids(include_ids, products)  # Ensure this function returns serialized data

    # Serialize products using to_dict method
    products_serialized = [product.to_dict() for product in products]
    return jsonify(products_serialized)


@app.route('/products/categories/<int:category_id>', methods=['GET'])
def fetch_category_by_id(category_id):
    products = Product.query.filter(Product.categories.contains([{'id': category_id}])).all()
    return jsonify([p.to_dict() for p in products])


@app.route('/products/<int:product_id>/comments', methods=['POST'])
def add_product_comment(product_id):
    data = request.get_json()
    content = data.get('content')
    author = data.get('author')
    is_offensive = data.get('is_offensive')
    probability = data.get('probability')
    if not content:
        return jsonify({"error": "Content is required"}), 400

    product = Product.query.get(product_id)
    if product is None:
        return jsonify({"error": "Id not found"}), 404

    response = requests.post(args.comments_api_gateway, json={"author": str(author), "content": str(content), "is_offensive": is_offensive, "probability": probability})
    if response.status_code != 200:
        return jsonify({"error": "Error calling comment filter service"}), 500

    result = response.json()
    if result.get("is_offensive", [1])[0]:
        # Comment is allowed, add it to the database
        comment = Comment(content=content, product_id=product.id)
        db.session.add(comment)
        db.session.commit()

        response_data = comment.to_dict()
        response_data.update({
            "author": author,
            "is_offensive": result.get("is_offensive"),
            "probability": result.get("probability")
        })

        return jsonify(response_data), 201

        # return jsonify(comment.to_dict(), result), 201
    else:
        # Comment is not allowed
        response_data = {"error": "Comment is not allowed"}
        response_data.update(result)
        return jsonify(response_data), 400
        # return jsonify({"error": "Comment is not allowed"}, result), 400

    # comment = Comment(content=content, product_id=product.id)
    # db.session.add(comment)
    # db.session.commit()

    # return jsonify(comment.to_dict()), 201

@app.route('/products/<int:product_id>/comments', methods=['GET'])
def fetch_product_comments(product_id):
    product = Product.query.get(product_id)
    if product is None:
        return jsonify({"error": "Id not found"}), 404

    comments = [comment.to_dict() for comment in product.comments]
    return jsonify(comments)



@app.route('/products/<int:product_id>', methods=['GET'])
def fetch_product_by_id(product_id):
    product = get_product_by_id(product_id)
    if product is None:
        return jsonify({'error': 'Id not found'}), 404
    return jsonify(product.to_dict())  # Assuming to_dict is implemented in the Id model


@app.route('/api/image-preprocessing', methods=['OPTIONS', 'POST'])
def image_preprocessing():
    return jsonify({'Error': 'Error preprocessing images: An error occurred while trying to preprocess the images. Please try again later.\n For more details, visit our GitHub repository: https://github.com/orcasecurity-research/image-preprocessing-ai-goat'}), 500

# @app.route('/products/suggestions', methods=['GET'])
# def fetch_product_suggestions():
#     products = load_products()
#     # Select 4 random products for suggestion
#     suggested_products = random.sample(products, 4)
#     return jsonify(suggested_products)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
