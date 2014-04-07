<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns="urn:schemas-microsoft-com:office:spreadsheet"
                xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="utf-8"
                indent="yes" />
    <xsl:strip-space elements="*" />
    <!-- 
        This xsl is for transforming a microsoft excel spreadsheet (xls/x)
        saved as a 'xml spreadsheet 2003' into a more plain xml document,
        so that it can be tracked more clearly in git but still remain
        openable by excel.
        
        The result copies out the workbook, worksheet, table, row, cell and 
        (optionally) data nodes; removing all settings, styles, and formatting. 
      -->
    <!-- 
        template to suppress text() 
      -->
    <xsl:template match="text()" />
    <!-- 
        template to create root node from workbook element.
        in order to be recognised by excel as a xml spreadsheet, the output
        workbook node seems to need both a xmlns and xmlns:ss namespace using
        "urn:schemas-microsoft-com:office:spreadsheet"
      -->
    <xsl:template match="ss:Workbook">
        <Workbook xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
            <xsl:apply-templates select="ss:Worksheet" />
        </Workbook>
    </xsl:template>
    <!--
        template to create worksheet nodes and its name attribute
      -->
    <xsl:template match="ss:Worksheet">
        <xsl:element name="Worksheet">
            <xsl:attribute name="ss:Name">
                <xsl:value-of select="@ss:Name" />
            </xsl:attribute>
            <xsl:apply-templates select="ss:Table" />
        </xsl:element>
    </xsl:template>
    <!--
        template to create table node within each worksheet
      -->
    <xsl:template match="ss:Table">
        <xsl:element name="Table">
            <xsl:apply-templates select="ss:Row" />
        </xsl:element>
    </xsl:template>
    <!--
        template to create row nodes within each table
      -->
    <xsl:template match="ss:Row">
        <xsl:element name="Row">
            <xsl:apply-templates select="ss:Cell" />
        </xsl:element>
    </xsl:template>
    <!--
        template to create cell nodes within each row
        if the cell has data, include the type attribute and the value
      -->
    <xsl:template match="ss:Cell">
        <xsl:element name="Cell">
            <xsl:if test="ss:Data">
                <xsl:element name="Data">
                    <xsl:attribute name="ss:Type">
                        <xsl:value-of select="ss:Data/@ss:Type" />
                    </xsl:attribute>
                    <xsl:value-of select="ss:Data" />
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
