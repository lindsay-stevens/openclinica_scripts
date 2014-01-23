<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:odm="http://www.cdisc.org/ns/odm/v1.3" xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 OpenClinica-ODM1-3-0-OC1.xsd">
<xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>
<xsl:template match="/">
<xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef">
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
<xsl:variable name="vsinglequote">'</xsl:variable>
<xsl:variable name="vbackslashsinglequote">\'</xsl:variable>
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList">
<xsl:variable name="vCodeListOID">
<xsl:value-of select="@OID"/>
</xsl:variable>
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef/odm:CodeListRef[@CodeListOID=$vCodeListOID]">
<xsl:variable name="vItemOID"><xsl:value-of select="../@OID"/></xsl:variable>
<xsl:variable name="vItemName"><xsl:value-of select="../@Name"/></xsl:variable>
<xsl:variable name="vDataType"><xsl:value-of select="../@DataType"/></xsl:variable>
<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/odm:ItemRef[@ItemOID=$vItemOID]">
codes &lt;- c(
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$vCodeListOID]/odm:CodeListItem">
<xsl:if test="position()>1">,
</xsl:if><xsl:choose>
<xsl:when test="$vDataType='text'">'<xsl:value-of select="@CodedValue"/>'</xsl:when>
<xsl:otherwise><xsl:value-of select="@CodedValue"/></xsl:otherwise>
</xsl:choose>
</xsl:for-each>);
levs &lt;- c(
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$vCodeListOID]/odm:CodeListItem">
<xsl:if test="position()>1">,
</xsl:if>
<xsl:variable name="vFieldValue">
<xsl:value-of select="odm:Decode/odm:TranslatedText"/>
</xsl:variable><xsl:variable name="doublequote">
<xsl:call-template name="replace">
<xsl:with-param name="text" select="$vFieldValue" />
<xsl:with-param name="replace" select="$vsinglequote" />
<xsl:with-param name="by" select="$vbackslashsinglequote" />
</xsl:call-template>
</xsl:variable>
<xsl:variable name="cleanfield">
<xsl:call-template name="replace">
<xsl:with-param name="text" select="$doublequote" />
<xsl:with-param name="replace" select="'&#10;'" />
<xsl:with-param name="by" select="' '" />
</xsl:call-template>
</xsl:variable>'<xsl:value-of select="$cleanfield"/>'</xsl:for-each>);
<xsl:value-of select="$TableName"/>$f.<xsl:value-of select="$vItemName"/>&lt;-factor(match(<xsl:value-of select="$TableName"/>$<xsl:value-of select="$vItemName"/>,codes),levels=1:length(codes),labels=levs);
w&lt;-which(names(<xsl:value-of select="$TableName"/>)=="<xsl:value-of select="$vItemName"/>");
l&lt;- dim(<xsl:value-of select="$TableName"/>)[2];
if (w&lt;(l-1))<xsl:value-of select="$TableName"/>&lt;-<xsl:value-of select="$TableName"/>[,c(1:w,l,(1+w):(l-1))];
rm(l,w);
</xsl:if>
</xsl:for-each>
</xsl:for-each>
</xsl:template>
<xsl:template name="replace">
<xsl:param name="text" />
<xsl:param name="replace" />
<xsl:param name="by" />
<xsl:choose>
<xsl:when test="contains($text, $replace)">
<xsl:value-of select="substring-before($text,$replace)" />
<xsl:value-of select="$by" />
<xsl:call-template name="replace">
<xsl:with-param name="text"
select="substring-after($text,$replace)" />
<xsl:with-param name="replace" select="$replace" />
<xsl:with-param name="by" select="$by" />
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text" />
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:include href="xml_convert_dynamic_lookup.xsl"/> 
</xsl:stylesheet>