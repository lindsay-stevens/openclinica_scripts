<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="utf-8"
                indent="yes" />
    <xsl:strip-space elements="*" />
    <!-- 
        two templates are provided, collate-template and split-template. this
        is to solve a problem where there are more than one rulerefs for a 
        target. the openclinica rule validator requires that rulerefs for the
        same target are grouped within a rule assignment node. however excel
        cant deal with this structure and requires that the target is repeated.
        
        collate-template reads in a rule xml file with the target repeated 
        for each action and groups together actions for the same target. the input
        is a rule xml file created with excel, the output can be uploaded to openclinica.
        
        split-template reads in a rule xml file with the target grouped 
        with actions for that target, and splits them to have their own
        rule assignment nodes. the input is a rule xml file downloaded from openclinica,
        the output can be imported to excel.

        usage syntax:
        java -cp "path\to\saxon9he.jar" net.sf.saxon.Transform -s:rulesForExcel.xml -o:rulesForOpenClinica.xml -xsl:collateOrSplitRuleRefsByTarget.xsl -it:collate-template
        
        java -cp "path\to\saxon9he.jar" net.sf.saxon.Transform -s:rulesForOpenClinica.xml -o:rulesForExcel.xml -xsl:collateOrSplitRuleRefsByTarget.xsl -it:split-template
        
        where -s: is the source file, -o: is the output file, and -xsl: is the xsl file.
        -it: is the template to run, either collate-template or split-template
      -->
    <!--
        variable containing all the targets in the rule file
      -->
    <xsl:variable name="rules"
                  select="distinct-values(//Target)" />
    <!--
        group the rulerefs inside a rule assignment node based on the target
        copy the ruledef nodes as is
      -->
    <xsl:template match="RuleImport"
                  name="collate-template">
        <xsl:element name="RuleImport">
            <xsl:for-each-group group-by="$rules"
                                select="//RuleAssignment">
                <xsl:element name="RuleAssignment">
                    <xsl:element name="Target">
                        <xsl:value-of select="current-grouping-key()" />
                    </xsl:element>
                    <xsl:for-each select="current-group()">
                        <xsl:copy-of select="RuleRef[../Target=current-grouping-key()]" />
                    </xsl:for-each>
                </xsl:element>
            </xsl:for-each-group>
            <xsl:for-each select="//RuleDef">
                <xsl:copy-of select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!--
        split the rulerefs inside a rule assignment node based on the target
        copy the ruledef nodes as is
      -->
    <xsl:template match="RuleImport"
                  name="split-template">
        <xsl:element name="RuleImport">
            <xsl:for-each select="//RuleRef">
                <xsl:element name="RuleAssignment">
                    <xsl:element name="Target">
                        <xsl:value-of select="../Target" />
                    </xsl:element>
                    <xsl:copy>
                        <xsl:apply-templates mode="normalize"
                                             select="@*|node()" />
                    </xsl:copy>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="//RuleDef">
                <xsl:copy-of select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@*|node()"
                  mode="normalize">
        <xsl:copy>
            <xsl:apply-templates mode="normalize"
                                 select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    <xsl:template match="Message"
                  mode="normalize">
        <xsl:copy>
            <xsl:value-of select="normalize-space(.)" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
