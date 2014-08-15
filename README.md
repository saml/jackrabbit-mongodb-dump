copy of https://github.com/upperbounds/jcrhelpers

```
$ sbt
> console
> import saml.jcr._
> val c = Connection()
> val nodes = c.xpath("/jcr:root/content//element(*,cq:Page)")
> nodes.foreach { x => println(x.getPath) }
> c.all("/content/foo/bar").foreach( x => println(x.getPath) )
```