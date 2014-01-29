java -cp saxon-8.7.jar net.sf.saxon.Transform -o dnotes_data.xml extract.xml xml_convert_dnotes_data.xsl

java -cp saxon-8.7.jar net.sf.saxon.Transform -o dnotes_style.html dnotes_data.xml xml_convert_dnotes_style.xsl