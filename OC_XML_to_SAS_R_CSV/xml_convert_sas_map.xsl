<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:odm="http://www.cdisc.org/ns/odm/v1.3" xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 OpenClinica-ODM1-3-0-OC1.xsd">
<xsl:template match="/">
<xsl:element name="SXLEMAP">
<xsl:attribute name="version">1.2</xsl:attribute>
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
</xsl:element>
</xsl:template>
<xsl:template name="processtable">
<xsl:param name="TableName"/>
<xsl:param name="ItemGroupOID"/>
<xsl:variable name="vStudyName">
<xsl:call-template name="get_studyname"/>
</xsl:variable>
<xsl:element name="TABLE">
<xsl:attribute name="name"><xsl:value-of select="$TableName"/></xsl:attribute>
<xsl:element name="TABLE-PATH"><xsl:attribute name="syntax">XPATH</xsl:attribute>/<xsl:value-of select="$vStudyName"/>/<xsl:value-of select="$ItemGroupOID"/></xsl:element>
<xsl:element name="COLUMN">
<xsl:attribute name="Name">SubjectID</xsl:attribute>
<xsl:element name="PATH">/<xsl:value-of select="$vStudyName"/>/<xsl:value-of select="$ItemGroupOID"/>/SubjectID</xsl:element>
<xsl:element name="TYPE">character</xsl:element>
<xsl:element name="DATATYPE">string</xsl:element>
<xsl:element name="LENGTH">50</xsl:element>
</xsl:element>
<xsl:element name="COLUMN">
<xsl:attribute name="Name">StudyEvent</xsl:attribute>
<xsl:element name="PATH">/<xsl:value-of select="$vStudyName"/>/<xsl:value-of select="$ItemGroupOID"/>/StudyEvent</xsl:element>
<xsl:element name="TYPE">character</xsl:element>
<xsl:element name="DATATYPE">string</xsl:element>
<xsl:element name="LENGTH">255</xsl:element>
</xsl:element>
<xsl:element name="COLUMN">
<xsl:attribute name="Name">StudyEventRepeatKey</xsl:attribute>
<xsl:element name="PATH">/<xsl:value-of select="$vStudyName"/>/<xsl:value-of select="$ItemGroupOID"/>/StudyEventRepeatKey</xsl:element>
<xsl:element name="TYPE">numeric</xsl:element>
<xsl:element name="DATATYPE">integer</xsl:element>
</xsl:element>
<xsl:element name="COLUMN">
<xsl:attribute name="Name">ItemGroupRepeatKey</xsl:attribute>
<xsl:element name="PATH">/<xsl:value-of select="$vStudyName"/>/<xsl:value-of select="$ItemGroupOID"/>/ItemGroupRepeatKey</xsl:element>
<xsl:element name="TYPE">numeric</xsl:element>
<xsl:element name="DATATYPE">integer</xsl:element>
</xsl:element>
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/odm:ItemRef">
<xsl:variable name="vitemOID">
<xsl:value-of select="@ItemOID"/>
</xsl:variable>
<xsl:variable name="vStringLength">
<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/@Length"/>
</xsl:variable>
<xsl:element name="COLUMN">
<xsl:attribute name="Name"><xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/@Name"/></xsl:attribute>
<xsl:element name="PATH">/<xsl:value-of select="$vStudyName"/>/<xsl:value-of select="$ItemGroupOID"/>/<xsl:value-of select="$vitemOID"/></xsl:element>
<xsl:variable name="vDataType">
<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/@DataType"/>
</xsl:variable>
<xsl:choose>
<xsl:when test="$vDataType='date'">
<xsl:element name="TYPE">character</xsl:element>
<xsl:element name="DATATYPE">date</xsl:element>
</xsl:when>
<xsl:when test="$vDataType='float'">
<xsl:element name="TYPE">numeric</xsl:element>
<xsl:element name="DATATYPE">double</xsl:element>
</xsl:when>
<xsl:when test="$vDataType='integer'">
<xsl:element name="TYPE">numeric</xsl:element>
<xsl:element name="DATATYPE">integer</xsl:element>
</xsl:when>
<xsl:when test="$vDataType='partialDate'">
<xsl:element name="TYPE">character</xsl:element>
<xsl:element name="DATATYPE">string</xsl:element>
<xsl:element name="LENGTH">20</xsl:element>
</xsl:when>
<xsl:when test="$vDataType='text'">
<xsl:element name="TYPE">character</xsl:element>
<xsl:element name="DATATYPE">string</xsl:element>
<xsl:if test="$vStringLength &gt; 255">
<xsl:element name="LENGTH">255</xsl:element>
</xsl:if>
<xsl:if test="$vStringLength &lt; 256">
<xsl:element name="LENGTH"><xsl:value-of select="$vStringLength"/></xsl:element>
</xsl:if>
</xsl:when>
<xsl:otherwise>
<xsl:element name="DataType">UNKNOWN/<xsl:value-of select="$vDataType"/></xsl:element>
</xsl:otherwise>
</xsl:choose>
</xsl:element>
</xsl:for-each>
</xsl:element>
</xsl:template>
<xsl:include href="xml_convert_dynamic_lookup.xsl"/> 
</xsl:stylesheet>