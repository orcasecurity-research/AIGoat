import argparse
import json
import os
from flask import Flask
from models import db, Product, Category, User, Comment
from datetime import datetime

os.chdir(os.path.dirname(os.path.abspath(__file__)))

app = Flask(__name__)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


def parse_args():
    parser = argparse.ArgumentParser(description='Configure database connection parameters.')
    parser.add_argument('--db_user', type=str, default='pos_user', help='Database user')
    parser.add_argument('--db_password', type=str, default='password123', help='Database password')
    parser.add_argument('--db_host', type=str, default='localhost', help='Database host')
    parser.add_argument('--db_name', type=str, default='rds-database', help='Database name')
    return parser.parse_args()


def configure_app(app, db_user, db_password, db_host, db_name):
    app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{db_user}:{db_password}@{db_host}:5432/{db_name}'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


def safe_convert(value, target_type=float):
    if value in ('', None):
        return None
    try:
        return target_type(value)
    except ValueError:
        return None

def parse_datetime(date_str):
    if date_str:
        return datetime.fromisoformat(date_str.rstrip('Z'))
    return None

def safe_float(value):
    try:
        return float(value) if value not in ('', None) else None
    except ValueError:
        return None

def load_json(filename):
    with open(filename, 'r') as file:
        return json.load(file)

def migrate_products(products):
    for product_data in products:
        categories = []
        for category_data in product_data['categories']:
            category = db.session.get(Category, category_data['id'])
            if not category:
                category = Category(
                    id=category_data['id'],
                    name=category_data['name'],
                    slug=category_data['slug']
                )
                db.session.add(category)
            categories.append(category)

        product = Product(
            id=int(product_data['id']),
            name=product_data['name'],
            slug=product_data['slug'],
            permalink=product_data['permalink'],
            date_created=parse_datetime(product_data['date_created']),
            date_created_gmt=parse_datetime(product_data['date_created_gmt']),
            date_modified=parse_datetime(product_data['date_modified']),
            date_modified_gmt=parse_datetime(product_data['date_modified_gmt']),
            type=product_data['type'],
            status=product_data['status'],
            featured=product_data['featured'],
            catalog_visibility=product_data['catalog_visibility'],
            description=product_data['description'],
            short_description=product_data['short_description'],
            sku=product_data['sku'],
            price=safe_convert(product_data['price'], float),
            regular_price=safe_convert(product_data['regular_price'], float),
            sale_price=safe_convert(product_data['sale_price'], float),
            date_on_sale_from=parse_datetime(product_data['date_on_sale_from']),
            date_on_sale_from_gmt=parse_datetime(product_data['date_on_sale_from_gmt']),
            date_on_sale_to=parse_datetime(product_data['date_on_sale_to']),
            date_on_sale_to_gmt=parse_datetime(product_data['date_on_sale_to_gmt']),
            price_html=product_data['price_html'],
            on_sale=product_data['on_sale'],
            purchasable=product_data['purchasable'],
            total_sales=safe_convert(product_data['total_sales'], int),
            virtual=product_data['virtual'],
            downloadable=product_data['downloadable'],
            downloads=product_data['downloads'],
            download_limit=safe_convert(product_data['download_limit'], int),
            download_expiry=safe_convert(product_data['download_expiry'], int),
            external_url=product_data['external_url'],
            button_text=product_data['button_text'],
            tax_status=product_data['tax_status'],
            tax_class=product_data['tax_class'],
            manage_stock=product_data['manage_stock'],
            stock_quantity=safe_convert(product_data['stock_quantity'], int),
            stock_status=product_data['stock_status'],
            backorders=product_data['backorders'],
            backorders_allowed=product_data['backorders_allowed'],
            backordered=product_data['backordered'],
            sold_individually=product_data['sold_individually'],
            weight=product_data['weight'],
            dimensions=product_data['dimensions'],
            shipping_required=product_data['shipping_required'],
            shipping_taxable=product_data['shipping_taxable'],
            shipping_class=product_data['shipping_class'],
            shipping_class_id=safe_convert(product_data['shipping_class_id'], int),
            reviews_allowed=product_data['reviews_allowed'],
            average_rating=safe_convert(product_data['average_rating'], float),
            rating_count=safe_convert(product_data['rating_count'], int),
            parent_id=safe_convert(product_data['parent_id'], int),
            purchase_note=product_data['purchase_note'],
            categories=categories,
            tags=product_data['tags'],
            images=product_data['images'],
            attributes=product_data['attributes'],
            default_attributes=product_data['default_attributes'],
            variations=product_data['variations'],
            grouped_products=product_data['grouped_products'],
            meta_data=product_data['meta_data'],
            acf=product_data['acf'],
        )
        db.session.add(product)
        for comment_data in product_data.get('comments', []):
            comment = Comment(
                content=comment_data['content'],
                product_id=product.id
            )
            db.session.add(comment)

    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        print(f"An error occurred: {e}")


def migrate_categories(categories):
    for category_data in categories:
        existing_category = db.session.get(Category, category_data['id'])
        if existing_category:
            existing_category.name = category_data['name']
            existing_category.slug = category_data['slug']
            existing_category.parent = category_data['parent']
            existing_category.description = category_data['description']
            existing_category.display = category_data['display']
            existing_category.image_id = category_data['image']['id']
            existing_category.image_src = category_data['image']['src']
            existing_category.image_name = category_data['image']['name']
            existing_category.image_alt = category_data['image']['alt']
            existing_category.menu_order = category_data['menu_order']
            existing_category.count = category_data['count']
            existing_category.self_link = category_data['_links']['self'][0]['href']
            existing_category.collection_link = category_data['_links']['collection'][0]['href']
        else:
            new_category = Category(
                id=category_data['id'],
                name=category_data['name'],
                slug=category_data['slug'],
                parent=category_data['parent'],
                description=category_data['description'],
                display=category_data['display'],
                image_id=category_data['image']['id'],
                image_src=category_data['image']['src'],
                image_name=category_data['image']['name'],
                image_alt=category_data['image']['alt'],
                menu_order=category_data['menu_order'],
                count=category_data['count'],
                self_link=category_data['_links']['self'][0]['href'],
                collection_link=category_data['_links']['collection'][0]['href']
            )
            db.session.add(new_category)

    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        print(f"An error occurred during category migration: {e}")



def migrate_users(users):
    for username, user_data in users.items():
        user = User(
            username=username,
            cart=user_data['cart'],
            recommendations=user_data['recommendations']
        )
        db.session.add(user)
    db.session.commit()

if __name__ == "__main__":
    with app.app_context():
        args = parse_args()
        configure_app(app, args.db_user, args.db_password, args.db_host, args.db_name)
        db.init_app(app)
        db.create_all()
        migrate_products(load_json('products.json'))
        migrate_categories(load_json('categories.json'))
        migrate_users(load_json('user_data.json'))
