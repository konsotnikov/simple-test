from flask import Flask
from flask import request
import mysql.connector

app = Flask(__name__)

# Connect to MySQL server
cnx = mysql.connector.connect(
    host="simple-rds-test.chderbmwygbw.us-east-2.rds.amazonaws.com", ##ToDo - remove hardcode here
    port=3306,
    user="root",
    password="Some_Password_12345")

# Get a cursor to manage database
cur = cnx.cursor(buffered=True)

# DB Create Route
@app.route('/dbcreate')
def dbcreate():
    cur.execute("CREATE DATABASE IF NOT EXISTS my_tests;")
    cnx.commit()
    return 'Test Database Created', 200, {'ContentType': 'application/json'}


# DB Delete Route
@app.route('/dbdrop')
def dbdrop():
    cur.execute("DROP DATABASE IF EXISTS my_tests;")
    cnx.commit()
    return 'Test Database Dropped', 200, {'ContentType': 'application/json'}


# Default Route
@app.route('/')
def index():
#    host_ip = request.remote_addr
#    return 'Do not Worry! <br /> App IP is ' + host_ip, 200, {'ContentType': 'application/json'}
    return 'Welcome to the SIMPLE TEST Project <br /> Do not Worry!', 200, {'ContentType': 'application/json'}


# Main func
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
