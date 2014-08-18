# check jcr.sql for schema

import argparse
import sqlite3
import os

class ValType(object):
    def __init__(self, ty, column_name):

TYPES = {
    bool: 0,
    int: 1,
    float: 2,
    datetime.datetime: 3,
    str: 4,
    unicode: 4
}


def type_of(val):
    return TYPES[type(val)]

class Db(object):
    def __init__(self, db):
        self.db = db

    def create_root(self, path, name):
        return self.db.execute('''INSERT INTO nodes(path, name, level) VALUES (?, ?, ?)''', (path, name, 0))

    def insert_val(self, prop_id, val):
        

    def insert_props(self, node_id, name, li):
        if len(li) > 0:
            v = li[0]
            prop_id = self.db.execute(
                '''INSERT INTO props(ty, node_id, is_multi, name) VALUES (?, ?, ?, ?)''', (type_of(v), node_id, True, name)).lastrowid

            for v in li:
                self.insert_val(prop_id, v)
                self.db.execute(
                        '''INSERT INTO vals(prop_id


    def insert_doc(db, doc):
        path = doc['path']
        name = os.path.basename(path)

        root_id = create_root(db, path, name).lastrowid
        for k,v in doc.items():
            ty = type(v)
            if ty == dict:
                insert_child(root_id, v)
            elif ty == list:
                insert_props(root_id, v)
            else:
                insert_prop(root_id, v)





if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--db', default='a.db', help='path to sqlite db file [%(default)s]')
    parser.add_argument('--schema', default='jcr.sql', help='schema to load [%(default)s]')
    args = parser.parse_args()

    conn = sqlite3.connect(args.db)
    with open(args.schema, 'rb') as f:
        conn.executescript(f.read())


