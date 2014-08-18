-- hierarchical db

/*
- a node has properties and children.
- children nodes are ordered.
- a property can be multiple value (an array).
- multiple property values are ordered.
- a value can be either boolean, date, long, ...
- a node can be considered a root node.
- many root nodes.

node/
  prop1
  prop2
  prop3
  child1/
    prop1
    prop2.0
    prop2.1
  child2/
    prop1
    child3/
      prop1.0
      prop1.2
node2/
  prop1
  child1/
    prop1


article1/
  title = 'abc'
  tags = ['a', 'b', 'c']
  image1/
    url = 'abc.jpg'
  par/
    text/
      text ='hello'


-- article1/
INSERT INTO nodes(path,name,level) VALUES ("article1", "article1", 0); -- rowid = 0
INSERT INTO props(ty,node_id,is_multi,name) VALUES (4, 0, false, 'title'); -- rowid = 0
INSERT INTO props(ty,node_id,is_multi,name) VALUES (4, 0, true, 'tags'); -- rowid = 1
INSERT INTO vals(prop_id,str_val) VALUES (0, 'abc'); -- title
INSERT INTO vals(prop_id,str_val) VALUES (1, 'a'); -- tags
INSERT INTO vals(prop_id,str_val) VALUES (1, 'b');
INSERT INTO vals(prop_id,str_val) VALUES (1, 'c');

-- article1/image1/
INSERT INTO nodes(path,name,level,parent_id,root_id,ord) VALUES('article1/image1','image1',1,0,0,0); -- node 1
INSERT INTO props(ty,node_id,is_multi,name) VALUES(4, 1, false, 'url'); -- prop 2
INSERT INTO vals(prop_id,str_val) VALUES(2, 'abc.jpg');

-- article
*/

CREATE TABLE IF NOT EXISTS nodes (
  path VARCHAR UNIQUE NOT NULL,
  name VARCHAR NOT NULL,
  level INTEGER NOT NULL, -- 0 means root node.
  parent_id INTEGER,      -- immediate parent.
  root_id INTEGER,        -- root node.
  ord INTEGER,            -- child nodes are ordered.
  FOREIGN KEY(parent_id) REFERENCES nodes(rowid),
  FOREIGN KEY(root_id) REFERENCES nodes(rowid)
);

-- a property has a name and a value, or multiple values (of same type).
CREATE TABLE IF NOT EXISTS props (
  ty INTEGER NOT NULL, -- vals table column index: 0 bool, 1 long, 2 double, 3 datetime, 4 string
  node_id INTEGER NOT NULL,
  is_multi BOOLEAN NOT NULL,
  name VARCHAR NOT NULL,
  FOREIGN KEY(node_id) REFERENCES nodes(rowid) 
);

-- only one column should be set.
CREATE TABLE IF NOT EXISTS vals (
  prop_id INTEGER NOT NULL,
  bool_val BOOLEAN,
  long_val LONG,
  double_val DOUBLE,
  date_val DATETIME,
  str_val VARCHAR,
  FOREIGN KEY(prop_id) REFERENCES props(rowid)
);

/*
CREATE TABLE IF NOT EXISTS props_vals (
  prop_id INTEGER NOT NULL,
  val_id INTEGER NOT NULL,
  FOREIGN KEY(prop_id) REFERENCES props(rowid),
  FOREIGN KEY(val_id) REFERENCES vals(rowid)
);


CREATE TABLE IF NOT EXISTS nodes_props(
  node_id INTEGER NOT NULL,
  prop_id INTEGER NOT NULL,
  FOREIGN KEY(node_id) REFERENCES nodes(rowid),
  FOREIGN KEY(prop_id) REFERENCES props(rowid)
);

CREATE TABLE IF NOT EXISTS nodes_nodes(
  ord INTEGER NOT NULL, -- child order.
  parent_id INTEGER NOT NULL,
  child_id INTEGER NOT NULL,
  FOREIGN KEY(parent_id) REFERENCES nodes(rowid),
  FOREIGN KEY(child_id) REFERENCES nodes(rowid)
);

-- root node?
CREATE TABLE IF NOT EXISTS pages (
  path VARCHAR PRIMARY KEY
);
*/
