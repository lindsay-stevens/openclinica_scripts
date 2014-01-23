<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:odm="http://www.cdisc.org/ns/odm/v1.3" xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 OpenClinica-ODM1-3-0-OC1.xsd">
<xsl:output method="text" omit-xml-declaration="yes"/>
<xsl:template match="/">
<xsl:variable name="vStudyName">
<xsl:call-template name="get_studyname"/>
</xsl:variable>
proc datasets library=<xsl:value-of select="$vStudyName"/>;
copy out=work;
run;
proc format;
<xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList"><xsl:if test="@DataType='text'">value $<xsl:value-of select="@OID"/>_ <xsl:for-each select="odm:CodeListItem/odm:Decode">"<xsl:value-of select="../@CodedValue"/>"="<xsl:value-of select="odm:TranslatedText"/>" </xsl:for-each>;
</xsl:if><xsl:if test="@DataType='integer'">value <xsl:value-of select="@OID"/>_ <xsl:for-each select="odm:CodeListItem/odm:Decode"><xsl:value-of select="../@CodedValue"/>="<xsl:value-of select="odm:TranslatedText"/>" </xsl:for-each>;
</xsl:if>
</xsl:for-each>
run;
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef">
<xsl:variable name="vitemgrouprefOID">
<xsl:value-of select="@OID"/>
</xsl:variable>
<xsl:variable name="vFormName">
<xsl:value-of select="substring-before(/odm:ODM/odm:Study/odm:MetaDataVersion/odm:FormDef/odm:ItemGroupRef[@ItemGroupOID=$vitemgrouprefOID]/../@Name,' -')"/>
</xsl:variable>
<xsl:variable name="vTableName">
<xsl:call-template name="get_tablename">
<xsl:with-param name="formname" select="$vFormName"/>
<xsl:with-param name="groupname" select="@Name"/>
<xsl:with-param name="groupid" select="@OID"/>
</xsl:call-template>
</xsl:variable>
<xsl:call-template name="processtable">
<xsl:with-param name="TableName" select="$vTableName"/>
<xsl:with-param name="ItemGroupOID" select="@OID"/>
</xsl:call-template>
</xsl:for-each>
</xsl:template>
<xsl:template name="processtable">
<xsl:param name="TableName"/>
<xsl:param name="ItemGroupOID"/>
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/odm:ItemRef">
<xsl:variable name="vitemOID">
<xsl:value-of select="@ItemOID"/>
</xsl:variable>
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/odm:CodeListRef">
data <xsl:value-of select="$TableName"/>;
set <xsl:value-of select="$TableName"/>;
format <xsl:value-of select="../@Name"/><xsl:text> </xsl:text><xsl:if test="../@DataType = 'text'">$</xsl:if><xsl:value-of select="@CodeListOID"/>_.;
run;
</xsl:for-each>
</xsl:for-each>
</xsl:template>
<xsl:include href="xml_convert_dynamic_lookup.xsl"/> 
</xsl:stylesheet>