<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="utf-8"
                indent="yes" />
    <xsl:strip-space elements="*" />
    <!-- 
        variable for selecting files to combine, relative to the location
        of the xsl file, for example the current setting would process all
        the xml files in the subfolders in the following:
        - crfsfolder
          (outputfilename.xml)
          - crf1
            rule1.xml
            rule2.xml
          - crf2
            rule1.xml
            rule2.xml
        commandline usage (all on one line, called from crfsfolder directory):
        path/to/java -cp path/to/saxon-8.7.jar net.sf.saxon.Transform -o 
        outputfilename.xml -it collate-template path/to/collate_rules.xsl 
      -->
    <xsl:variable name="rules"
                  select="collection('?select=*.xml;recurse=yes;on-error=warning')" />
    <!--
        read files in the above collection, combine into one file
      -->
    <xsl:template match="/"
                  name="collate-template">
        <xsl:element name="RuleImport">
            <xsl:for-each select="$rules">
                <xsl:copy-of select="RuleImport/RuleAssignment" />
            </xsl:for-each>
            <xsl:for-each select="$rules">
                <xsl:copy-of select="RuleImport/RuleDef" />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>