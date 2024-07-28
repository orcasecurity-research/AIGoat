#!/bin/bash

echo "operator_package_upgrade=false" >> /etc/ecs/ecs.config
# Install dependencies
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib
sudo apt-get install -y python3-pip
pip3 install -r requirements.txt

# Set environment variables
echo "FLASK_APP=app.py" >> ~/.bashrc
echo "DATABASE_URL=postgresql://pos_user:password123@${aws_db_instance.rds.endpoint}/rds-database" >> ~/.bashrc
source ~/.bashrc

# Run migrations
python3 migrate_data.py
nohup python3 app.py --host=0.0.0.0 &