# Copy a file to a destination with shutil.copyfileobj()
import shutil
import json
import csv

source_file_path = '/home/deploy/consul/current/public/machine_learning/data/comments.json'
source_file = open(source_file_path, 'rb')
destination_file_path = '/home/deploy/consul/current/public/machine_learning/data/ml_comments.json'
csv_file_path = '/home/deploy/consul/current/public/machine_learning/data/ml_comments.csv'
destination_file = open(destination_file_path, 'wb')
shutil.copyfileobj(source_file, destination_file)
source_file.close()
destination_file.close()


def convert_json_to_csv(json_file, csv_file, debug_file=None):
    if debug_file:
        with open(debug_file, 'w') as file:
            file.write(f"JSON file: {json_file}\n")
            file.write(f"CSV file: {csv_file}\n")
            file.write("Conversion completed successfully.\n")

    print ("insede function")
    with open(json_file, 'r') as file:
        data = json.load(file)

    with open(csv_file, 'w', newline='') as file:
        writer = csv.writer(file)
        
        # Write header row
        writer.writerow(data[0].keys())
        
        # Write data rows
        for item in data:
            writer.writerow(item.values())
    
            
json_file_path = source_file_path
csv_file_path = '../data/ml_comments.csv'
debug_file_path = 'debug.txt'
print("about to call function")
convert_json_to_csv(json_file_path, csv_file_path, debug_file_path)