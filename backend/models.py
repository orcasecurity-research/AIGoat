from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

product_categories = db.Table('product_categories',
    db.Column('product_id', db.Integer, db.ForeignKey('product.id'), primary_key=True),
    db.Column('category_id', db.Integer, db.ForeignKey('category.id'), primary_key=True)
)

class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True, nullable=False)
    slug = db.Column(db.String(80), unique=True, nullable=False)
    permalink = db.Column(db.String(255), nullable=False)
    date_created = db.Column(db.DateTime, nullable=False)
    date_created_gmt = db.Column(db.DateTime, nullable=False)
    date_modified = db.Column(db.DateTime, nullable=False)
    date_modified_gmt = db.Column(db.DateTime, nullable=False)
    type = db.Column(db.String(20), nullable=False)
    status = db.Column(db.String(20), nullable=False)
    featured = db.Column(db.Boolean, default=False)
    catalog_visibility = db.Column(db.Boolean, default=True)
    description = db.Column(db.Text, nullable=False)
    short_description = db.Column(db.Text, nullable=False)
    sku = db.Column(db.String(50), nullable=False)
    price = db.Column(db.Float, nullable=False)
    regular_price = db.Column(db.Float, nullable=False)
    sale_price = db.Column(db.Float)
    date_on_sale_from = db.Column(db.DateTime)
    date_on_sale_from_gmt = db.Column(db.DateTime)
    date_on_sale_to = db.Column(db.DateTime)
    date_on_sale_to_gmt = db.Column(db.DateTime)
    price_html = db.Column(db.String(255))
    on_sale = db.Column(db.Boolean, default=False)
    purchasable = db.Column(db.Boolean, default=True)
    total_sales = db.Column(db.Integer, default=0)
    virtual = db.Column(db.Boolean, default=False)
    downloadable = db.Column(db.Boolean, default=False)
    downloads = db.Column(db.JSON)
    download_limit = db.Column(db.Integer, default=0)
    download_expiry = db.Column(db.Integer, default=0)
    external_url = db.Column(db.String(255))
    button_text = db.Column(db.String(50))
    tax_status = db.Column(db.String(20))
    tax_class = db.Column(db.String(20))
    manage_stock = db.Column(db.Boolean, default=False)
    stock_quantity = db.Column(db.Integer)
    stock_status = db.Column(db.String(20))
    backorders = db.Column(db.String(20))
    backorders_allowed = db.Column(db.Boolean, default=False)
    backordered = db.Column(db.Boolean, default=False)
    sold_individually = db.Column(db.Boolean, default=False)
    weight = db.Column(db.String(20))
    dimensions = db.Column(db.JSON)
    shipping_required = db.Column(db.Boolean, default=True)
    shipping_taxable = db.Column(db.Boolean, default=True)
    shipping_class = db.Column(db.String(50))
    shipping_class_id = db.Column(db.Integer, default=0)
    reviews_allowed = db.Column(db.Boolean, default=True)
    average_rating = db.Column(db.Float, default=0.0)
    rating_count = db.Column(db.Integer, default=0)
    parent_id = db.Column(db.Integer, default=0)
    purchase_note = db.Column(db.String(255))
    categories = db.relationship('Category', secondary='product_categories', lazy='subquery')
    tags = db.Column(db.JSON)
    images = db.Column(db.JSON)
    attributes = db.Column(db.JSON)
    default_attributes = db.Column(db.JSON)
    variations = db.Column(db.JSON)
    grouped_products = db.Column(db.JSON)
    meta_data = db.Column(db.JSON)
    acf = db.Column(db.JSON)
    comments = db.relationship('Comment', backref='product', lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "slug": self.slug,
            "permalink": self.permalink,
            "date_created": self.date_created,
            "date_created_gmt": self.date_created_gmt,
            "date_modified": self.date_modified,
            "date_modified_gmt": self.date_modified_gmt,
            "type": self.type,
            "status": self.status,
            "featured": self.featured,
            "catalog_visibility": self.catalog_visibility,
            "description": self.description,
            "short_description": self.short_description,
            "sku": self.sku,
            "price": self.price,
            "regular_price": self.regular_price,
            "sale_price": self.sale_price,
            "date_on_sale_from": self.date_on_sale_from,
            "date_on_sale_from_gmt": self.date_on_sale_from_gmt,
            "date_on_sale_to": self.date_on_sale_to,
            "date_on_sale_to_gmt": self.date_on_sale_to_gmt,
            "price_html": self.price_html,
            "on_sale": self.on_sale,
            "purchasable": self.purchasable,
            "total_sales": self.total_sales,
            "virtual": self.virtual,
            "downloadable": self.downloadable,
            "downloads": self.downloads,
            "download_limit": self.download_limit,
            "download_expiry": self.download_expiry,
            "external_url": self.external_url,
            "button_text": self.button_text,
            "tax_status": self.tax_status,
            "tax_class": self.tax_class,
            "manage_stock": self.manage_stock,
            "stock_quantity": self.stock_quantity,
            "stock_status": self.stock_status,
            "backorders": self.backorders,
            "backorders_allowed": self.backorders_allowed,
            "backordered": self.backordered,
            "sold_individually": self.sold_individually,
            "weight": self.weight,
            "dimensions": self.dimensions,
            "shipping_required": self.shipping_required,
            "shipping_taxable": self.shipping_taxable,
            "shipping_class": self.shipping_class,
            "shipping_class_id": self.shipping_class_id,
            "reviews_allowed": self.reviews_allowed,
            "average_rating": self.average_rating,
            "rating_count": self.rating_count,
            "parent_id": self.parent_id,
            "purchase_note": self.purchase_note,
            "categories": [category.to_dict() for category in self.categories],
            "tags": self.tags,
            "images": self.images,
            "attributes": self.attributes,
            "default_attributes": self.default_attributes,
            "variations": self.variations,
            "grouped_products": self.grouped_products,
            "meta_data": self.meta_data,
            "acf": self.acf,
            "comments": [comment.to_dict() for comment in self.comments]
        }


class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    slug = db.Column(db.String(255), nullable=False)
    parent = db.Column(db.Integer, nullable=False, default=0)
    description = db.Column(db.String(255), default='')
    display = db.Column(db.String(50), default='default')
    image_id = db.Column(db.Integer)
    image_src = db.Column(db.String(255))
    image_name = db.Column(db.String(255))
    image_alt = db.Column(db.String(255))
    menu_order = db.Column(db.Integer)
    count = db.Column(db.Integer)
    self_link = db.Column(db.String(255))
    collection_link = db.Column(db.String(255))

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "slug": self.slug,
            "parent": self.parent,
            "description": self.description,
            "display": self.display,
            "image": {
                "id": self.image_id,
                "src": self.image_src,
                "name": self.image_name,
                "alt": self.image_alt
            },
            "menu_order": self.menu_order,
            "count": self.count,
            "_links": {
                "self": [{"href": self.self_link}],
                "collection": [{"href": self.collection_link}]
            }
        }



class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    cart = db.Column(db.PickleType, nullable=False, default=[])
    recommendations = db.Column(db.PickleType, nullable=False, default=[])

    def to_dict(self):
        return {
            "id": self.id,
            "username": self.username,
            "cart": self.cart,
            "recommendations": self.recommendations,
        }

class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.String(255), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'))

    def to_dict(self):
        return {
            "id": self.id,
            "content": self.content
        }
