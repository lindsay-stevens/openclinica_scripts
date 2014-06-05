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
<xsl:param name="ItemGroupOID"/>TableName:<xsl:value-of select="$TableName"/>
"SubjectID","EventName","StudyEventRepeatKey","CRFName","ItemGroupRepeatKey"<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/odm:ItemRef">
<xsl:variable name="vItemOID">
<xsl:value-of select="@ItemOID"/>
</xsl:variable>,"<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vItemOID]/@Name"/>"</xsl:for-each><xsl:text>&#10;</xsl:text>
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:variable name="vStudyOID"><xsl:value-of select="../../../../@StudyOID"/></xsl:variable>

<xsl:variable name="vSubjectKey"><xsl:value-of select="../../../@SubjectKey"/></xsl:variable>
<xsl:variable name="vStudyEventOID"><xsl:value-of select="../../@StudyEventOID"/></xsl:variable>
<xsl:variable name="vStudyEventRepeatKey"><xsl:value-of select="../../@StudyEventRepeatKey"/></xsl:variable>
<xsl:variable name="vFormOID"><xsl:value-of select="../@FormOID"/></xsl:variable>
<xsl:variable name="vItemGroupRepeatKey"><xsl:value-of select="@ItemGroupRepeatKey"/>
</xsl:variable>"<xsl:value-of select="../../../@OpenClinica:StudySubjectID"/>","<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:StudyEventDef[@OID=$vStudyEventOID]/@Name"/>",<xsl:value-of select="../../@StudyEventRepeatKey"/>,"<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:FormDef[@OID=$vFormOID]/@Name"/>",<xsl:value-of select="@ItemGroupRepeatKey"/><xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/odm:ItemRef">
<xsl:variable name="vItemOID"><xsl:value-of select="@ItemOID"/></xsl:variable>
<xsl:variable name="vDataType">
<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vItemOID]/@DataType"/>
</xsl:variable>
<xsl:choose>
<xsl:when test="/odm:ODM/odm:ClinicalData[@StudyOID=$vStudyOID]/odm:SubjectData[@SubjectKey=$vSubjectKey]/odm:StudyEventData[@StudyEventOID=$vStudyEventOID and (@StudyEventRepeatKey=$vStudyEventRepeatKey or not (@StudyEventRepeatKey))]/odm:FormData[@FormOID=$vFormOID]/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID and (@ItemGroupRepeatKey=$vItemGroupRepeatKey or not(@ItemGroupRepeatKey))]/odm:ItemData[@ItemOID=$vItemOID]">
<xsl:variable name="vFieldValue"><xsl:value-of select="/odm:ODM/odm:ClinicalData[@StudyOID=$vStudyOID]/odm:SubjectData[@SubjectKey=$vSubjectKey]/odm:StudyEventData[@StudyEventOID=$vStudyEventOID and (@StudyEventRepeatKey=$vStudyEventRepeatKey or not (@StudyEventRepeatKey))]/odm:FormData[@FormOID=$vFormOID]/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID and (@ItemGroupRepeatKey=$vItemGroupRepeatKey or not(@ItemGroupRepeatKey))]/odm:ItemData[@ItemOID=$vItemOID]/@Value"/></xsl:variable>
<xsl:choose><xsl:when test="$vDataType='text'">
<xsl:variable name="doublequote">
<xsl:call-template name="replace">
<xsl:with-param name="text" select="$vFieldValue" />
<xsl:with-param name="replace" select="'&#34;'" />
<xsl:with-param name="by" select="'&#34;&#34;'" />
</xsl:call-template>
</xsl:variable>
<xsl:variable name="cleanfield">
<xsl:call-template name="replace">
<xsl:with-param name="text" select="$doublequote" />
<xsl:with-param name="replace" select="'&#10;'" />
<xsl:with-param name="by" select="' '" />
</xsl:call-template>
</xsl:variable>,"<xsl:value-of select="$cleanfield"/>"</xsl:when>
<xsl:otherwise>,<xsl:value-of select="$vFieldValue"/></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise>,</xsl:otherwise></xsl:choose>
</xsl:for-each><xsl:text>&#10;</xsl:text>
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