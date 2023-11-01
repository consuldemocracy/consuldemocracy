# Copy a file to a destination with shutil.copyfileobj()
import shutil
source_file_path = '/home/deploy/consul/current/public/machine_learning/data/comments.json'
source_file = open(source_file_path, 'rb')
destination_file_path = '/home/deploy/consul/current/public/machine_learning/data/ml_comments.json'
destination_file = open(destination_file_path, 'wb')
shutil.copyfileobj(source_file, destination_file)