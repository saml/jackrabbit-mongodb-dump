# check jcr.sql for schema

import argparse
import sqlite3
import os

def create_root(db, path, name):
    return db.execute('''INSERT INTO nodes(path, name, level) VALUES (?, ?, ?)''', path, name, 0)


def insert_doc(db, doc):
    path = doc['path']
    name = os.path.basename(path)

    create_root(db, path, name)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--db', default='a.db', help='path to sqlite db file [%(default)s]')
    parser.add_argument('--schema', default='jcr.sql', help='schema to load [%(default)s]')
    args = parser.parse_args()

    conn = sqlite3.connect(args.db)
    with open(args.schema, 'rb') as f:
        conn.executescript(f.read())


