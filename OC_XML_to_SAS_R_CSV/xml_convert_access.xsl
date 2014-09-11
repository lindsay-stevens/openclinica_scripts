<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:odm="http://www.cdisc.org/ns/odm/v1.3" xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 OpenClinica-ODM1-3-0-OC1.xsd">




<xsl:template match="/">

<ODM>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:od="urn:schemas-microsoft-com:officedata">
<xsd:element name="dataroot">
<xsd:complexType>
<xsd:sequence>
<xsd:element ref="Study" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyMeasurementUnit" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyCodeListItem" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyMultiSelectListItem" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyFormStatus" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyEventForms" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyFormItemGroups" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyItem" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyItemGroupItems" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyRangeCheckItem" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyUsers" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyDataDiscrepancyNotes" minOccurs="0" maxOccurs="unbounded"/>
<xsd:element ref="StudyDataDiscrepancyNoteUpdates" minOccurs="0" maxOccurs="unbounded"/>
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
        <xsl:element name="xsd:element">
         <xsl:attribute name="ref"><xsl:value-of select="$vTableName"/></xsl:attribute>
         <xsl:attribute name="minOccurs">0</xsl:attribute>
         <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
        </xsl:element>
       </xsl:for-each>

</xsd:sequence>
<xsd:attribute name="generated" type="xsd:dateTime"/>
</xsd:complexType>
</xsd:element>
<xsd:element name="Study">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="OID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyName" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ProtocolName" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ParentStudy" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyMeasurementUnit">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="OID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Name" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyCodeListItem">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="OID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Name" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DataType" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="CodedValue" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DecodeValue" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DecodeValueMemo" minOccurs="0" od:jetType="memo" od:sqlSType="ntext">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="536870910"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyMultiSelectListItem">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Name" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DataType" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="CodedValue" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DecodeValue" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DecodeValueMemo" minOccurs="0" od:jetType="memo" od:sqlSType="ntext">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="536870910"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyFormStatus">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="SubjectID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="SubjectKey" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="SubjectSecondaryID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyEventOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyEventRepeatKey" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyEventStatus" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyEventStartDate" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="FormOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="FormVersion" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="FormStatus" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="InterviewerName" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="InterviewDate" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyEventForms">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyEventOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyEventName" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="FormOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyFormItemGroups">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyFormOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyFormName" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ItemGroupOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyItem">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="OID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Name" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Comment" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DataType" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Length" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="SignificantDigits" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Question" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="QuestionMemo" minOccurs="0" od:jetType="memo" od:sqlSType="ntext">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="536870910"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="CodeListOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="MultiSelectListID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="MeasurementUnitOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyItemGroupItems">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ItemGroupOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ItemGroupName" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ItemOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyRangeCheckItem">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="OID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Comparator" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="CheckValue" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ErrorMessage" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyUsers">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="OID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="FullName" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="FirstName" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="LastName" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Organization" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyDataDiscrepancyNotes">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="SubjectID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyEventOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="StudyEventRepeatKey" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="FormOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ItemGroupOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ItemGroupRepeatKey" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ItemOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="ID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Status" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="NoteType" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DateUpdated" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="NumberOfUpdates" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
<xsd:element name="StudyDataDiscrepancyNoteUpdates">
<xsd:annotation>
<xsd:appinfo/>
</xsd:annotation>
<xsd:complexType>
<xsd:sequence>
<xsd:element name="StudyDataDiscrepancyNoteUpdatesID" minOccurs="1" od:jetType="autonumber" od:sqlSType="int" od:autoUnique="yes" od:nonNullable="yes" type="xsd:int"/>
<xsd:element name="StudyDataDiscrepancyNoteID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Status" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DateCreated" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="Description" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="DetailedNote" minOccurs="0" od:jetType="memo" od:sqlSType="ntext">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="536870910"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
<xsd:element name="UserOID" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
<xsd:simpleType>
<xsd:restriction base="xsd:string">
<xsd:maxLength value="255"/>
</xsd:restriction>
</xsd:simpleType>
</xsd:element>
</xsd:sequence>
</xsd:complexType>
</xsd:element>
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
     <xsl:element name="xsd:element">
      <xsl:attribute name="name"><xsl:value-of select="$vTableName"/></xsl:attribute>
      <xsl:element name="xsd:annotation">
       <xsl:element name="xsd:appinfo"></xsl:element>
      </xsl:element>
      <xsl:element name="xsd:complexType">
       <xsl:element name="xsd:sequence">
        <xsl:element name="xsd:element"> 
         <xsl:attribute name="name">SubjectID</xsl:attribute>
         <xsl:attribute name="minOccurs">0</xsl:attribute>
         <xsl:attribute name="od:jetType">text</xsl:attribute>
         <xsl:attribute name="od:sqlSType">nvarchar</xsl:attribute>
         <xsl:element name="xsd:simpleType">
          <xsl:element name="xsd:restriction">
           <xsl:attribute name="base">xsd:string</xsl:attribute>
           <xsl:element name="xsd:maxLength">
            <xsl:attribute name="value">255</xsl:attribute>
           </xsl:element>
          </xsl:element>
         </xsl:element>
        </xsl:element>
        <xsl:element name="xsd:element"> 
         <xsl:attribute name="name">EventName</xsl:attribute>
         <xsl:attribute name="minOccurs">0</xsl:attribute>
         <xsl:attribute name="od:jetType">text</xsl:attribute>
         <xsl:attribute name="od:sqlSType">nvarchar</xsl:attribute>
         <xsl:element name="xsd:simpleType">
          <xsl:element name="xsd:restriction">
           <xsl:attribute name="base">xsd:string</xsl:attribute>
           <xsl:element name="xsd:maxLength">
            <xsl:attribute name="value">255</xsl:attribute>
           </xsl:element>
          </xsl:element>
         </xsl:element>
        </xsl:element>
        <xsl:element name="xsd:element"> 
         <xsl:attribute name="name">StudyEventRepeatKey</xsl:attribute>
         <xsl:attribute name="minOccurs">0</xsl:attribute>
         <xsl:attribute name="od:jetType">longinteger</xsl:attribute>
         <xsl:attribute name="od:sqlSType">int</xsl:attribute>
         <xsl:attribute name="type">xsd:int</xsl:attribute>
        </xsl:element>
        <xsl:element name="xsd:element"> 
         <xsl:attribute name="name">CRFName</xsl:attribute>
         <xsl:attribute name="minOccurs">0</xsl:attribute>
         <xsl:attribute name="od:jetType">text</xsl:attribute>
         <xsl:attribute name="od:sqlSType">nvarchar</xsl:attribute>
         <xsl:element name="xsd:simpleType">
          <xsl:element name="xsd:restriction">
           <xsl:attribute name="base">xsd:string</xsl:attribute>
           <xsl:element name="xsd:maxLength">
            <xsl:attribute name="value">255</xsl:attribute>
           </xsl:element>
          </xsl:element>
         </xsl:element>
        </xsl:element>
        <xsl:element name="xsd:element"> 
         <xsl:attribute name="name">ItemGroupRepeatKey</xsl:attribute>
         <xsl:attribute name="minOccurs">0</xsl:attribute>
         <xsl:attribute name="od:jetType">text</xsl:attribute>
         <xsl:attribute name="od:sqlSType">nvarchar</xsl:attribute>
         <xsl:attribute name="od:jetType">longinteger</xsl:attribute>
         <xsl:attribute name="od:sqlSType">int</xsl:attribute>
         <xsl:attribute name="type">xsd:int</xsl:attribute>
        </xsl:element>
        <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$vitemgrouprefOID]/odm:ItemRef">
         <xsl:variable name="vitemOID">
          <xsl:value-of select="@ItemOID"/>
         </xsl:variable>
         <xsl:variable name="vStringLength">
          <xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/@Length"/>
         </xsl:variable>
         <xsl:variable name="vDataType">
          <xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/@DataType"/>
         </xsl:variable>
         <xsl:element name="xsd:element"> 
          <xsl:attribute name="name"><xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/@Name"/></xsl:attribute>
          <xsl:attribute name="minOccurs">0</xsl:attribute>
          <xsl:choose>
           <xsl:when test="$vDataType='date'">
            <xsl:attribute name="od:jetType">datetime</xsl:attribute>
            <xsl:attribute name="od:sqlSType">datetime</xsl:attribute>
            <xsl:attribute name="type">xsd:dateTime</xsl:attribute>
           </xsl:when>
           <xsl:when test="$vDataType='float'">
            <xsl:attribute name="od:jetType">double</xsl:attribute>
            <xsl:attribute name="od:sqlSType">float</xsl:attribute>
            <xsl:attribute name="type">xsd:double</xsl:attribute>
           </xsl:when>
           <xsl:when test="$vDataType='integer'">
            <xsl:attribute name="od:jetType">longinteger</xsl:attribute>
            <xsl:attribute name="od:sqlSType">int</xsl:attribute>
            <xsl:attribute name="type">xsd:int</xsl:attribute>
           </xsl:when>
           <xsl:when test="$vDataType='text' and $vStringLength &gt; 200">
            <xsl:attribute name="od:jetType">memo</xsl:attribute>
            <xsl:attribute name="od:sqlSType">ntext</xsl:attribute>
           </xsl:when>
           <xsl:otherwise>
            <xsl:attribute name="od:jetType">text</xsl:attribute>
            <xsl:attribute name="od:sqlSType">nvarchar</xsl:attribute>
           </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/odm:CodeListRef/@CodeListOID">
           <xsl:element name="xsd:annotation">
            <xsl:element name="xsd:appinfo">
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">DisplayControl</xsl:attribute>
              <xsl:attribute name="type">3</xsl:attribute>
              <xsl:attribute name="value">111</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">RowSourceType</xsl:attribute>
              <xsl:attribute name="type">10</xsl:attribute>
              <xsl:attribute name="value">Table/Query</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">RowSource</xsl:attribute>
              <xsl:attribute name="type">12</xsl:attribute>
              <xsl:attribute name="value">SELECT StudyCodeListItem.CodedValue, Nz(StudyCodeListItem.DecodeValue,Left(StudyCodeListItem.DecodeValueMemo,255)) FROM StudyCodeListItem WHERE (((StudyCodeListItem.OID)="<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/odm:CodeListRef/@CodeListOID"/>"));</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">BoundColumn</xsl:attribute>
              <xsl:attribute name="type">3</xsl:attribute>
              <xsl:attribute name="value">1</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">ColumnCount</xsl:attribute>
              <xsl:attribute name="type">3</xsl:attribute>
              <xsl:attribute name="value">2</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">ListWidth</xsl:attribute>
              <xsl:attribute name="type">10</xsl:attribute>
              <xsl:attribute name="value">5670twip</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">LimitToList</xsl:attribute>
              <xsl:attribute name="type">1</xsl:attribute>
              <xsl:attribute name="value">0</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">ColumnWidths</xsl:attribute>
              <xsl:attribute name="type">10</xsl:attribute>
              <xsl:attribute name="value">1134;4536</xsl:attribute>
             </xsl:element>
            </xsl:element>
           </xsl:element>
          </xsl:if>
          <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/OpenClinica:MultiSelectListRef/@MultiSelectListID">
           <xsl:element name="xsd:annotation">
            <xsl:element name="xsd:appinfo">
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">DisplayControl</xsl:attribute>
              <xsl:attribute name="type">3</xsl:attribute>
              <xsl:attribute name="value">111</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">RowSourceType</xsl:attribute>
              <xsl:attribute name="type">10</xsl:attribute>
              <xsl:attribute name="value">Table/Query</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">RowSource</xsl:attribute>
              <xsl:attribute name="type">12</xsl:attribute>
              <xsl:attribute name="value">SELECT StudyMultiSelectListItem.CodedValue, Nz(StudyMultiSelectListItem.DecodeValue,Left(StudyMultiSelectListItem.DecodeValueMemo,255)) FROM StudyMultiSelectListItem WHERE (((StudyMultiSelectListItem.ID)="<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vitemOID]/OpenClinica:MultiSelectListRef/@MultiSelectListID"/>"));</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">BoundColumn</xsl:attribute>
              <xsl:attribute name="type">3</xsl:attribute>
              <xsl:attribute name="value">1</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">ColumnCount</xsl:attribute>
              <xsl:attribute name="type">3</xsl:attribute>
              <xsl:attribute name="value">2</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">ListWidth</xsl:attribute>
              <xsl:attribute name="type">10</xsl:attribute>
              <xsl:attribute name="value">5670twip</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">LimitToList</xsl:attribute>
              <xsl:attribute name="type">1</xsl:attribute>
              <xsl:attribute name="value">0</xsl:attribute>
             </xsl:element>
             <xsl:element name="od:fieldProperty">
              <xsl:attribute name="name">ColumnWidths</xsl:attribute>
              <xsl:attribute name="type">10</xsl:attribute>
              <xsl:attribute name="value">1134;4536</xsl:attribute>
             </xsl:element>
            </xsl:element>
           </xsl:element>
          </xsl:if>
          <xsl:if test="$vDataType='text' and $vStringLength &gt; 200">
           <xsl:element name="xsd:simpleType">
            <xsl:element name="xsd:restriction">
             <xsl:attribute name="base">xsd:string</xsl:attribute>
             <xsl:element name="xsd:maxLength">
              <xsl:attribute name="value">536870910</xsl:attribute>
             </xsl:element>
            </xsl:element>
           </xsl:element>
          </xsl:if>
          <xsl:if test="$vDataType='text' and $vStringLength &lt; 201">
           <xsl:element name="xsd:simpleType">
            <xsl:element name="xsd:restriction">
             <xsl:attribute name="base">xsd:string</xsl:attribute>
             <xsl:element name="xsd:maxLength">
              <xsl:choose>
               <xsl:when test="$vStringLength &lt; 7">
                <xsl:attribute name="value">10</xsl:attribute>
               </xsl:when>
               <xsl:when test="$vStringLength &lt; 40 and $vStringLength &gt; 6">
                <xsl:attribute name="value">50</xsl:attribute>
               </xsl:when>
               <xsl:when test="$vStringLength &lt; 80 and $vStringLength &gt; 39">
                <xsl:attribute name="value">100</xsl:attribute>
               </xsl:when>
               <xsl:otherwise>
                <xsl:attribute name="value">255</xsl:attribute>
               </xsl:otherwise>
              </xsl:choose>
             </xsl:element>
            </xsl:element>
           </xsl:element>
          </xsl:if>
         </xsl:element>
        </xsl:for-each>

       </xsl:element>
      </xsl:element>
     </xsl:element>
    </xsl:for-each>

</xsd:schema>
      <xsl:for-each select="odm:ODM/odm:Study">
	<xsl:element name="Study">
	<xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
	<xsl:element name="StudyName"><xsl:value-of select="odm:GlobalVariables/odm:StudyName"/></xsl:element>
	<xsl:element name="ProtocolName"><xsl:value-of select="odm:GlobalVariables/odm:ProtocolName"/></xsl:element>
	<xsl:element name="ParentStudy"><xsl:value-of select="odm:MetaDataVersion/odm:Include/@StudyOID"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
      <xsl:for-each select="odm:ODM/odm:Study/odm:BasicDefinitions/odm:MeasurementUnit">
	<xsl:element name="StudyMeasurementUnit">
	<xsl:element name="StudyOID"><xsl:value-of select="../../@OID"/></xsl:element>
	<xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
	<xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
      <xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:StudyEventDef/odm:FormRef">
	<xsl:element name="StudyEventForms">
	<xsl:element name="StudyOID"><xsl:value-of select="../../../@OID"/></xsl:element>
	<xsl:element name="StudyEventOID"><xsl:value-of select="../@OID"/></xsl:element>
	<xsl:element name="StudyEventName"><xsl:value-of select="../@Name"/></xsl:element>
	<xsl:element name="FormOID"><xsl:value-of select="@FormOID"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
      <xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:FormDef/odm:ItemGroupRef">
	<xsl:element name="StudyFormItemGroups">
	<xsl:element name="StudyOID"><xsl:value-of select="../../../@OID"/></xsl:element>
	<xsl:element name="StudyFormOID"><xsl:value-of select="../@OID"/></xsl:element>
	<xsl:element name="StudyFormName"><xsl:value-of select="../@Name"/></xsl:element>
	<xsl:element name="ItemGroupOID"><xsl:value-of select="@ItemGroupOID"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
      <xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef/odm:ItemRef">
	<xsl:element name="StudyItemGroupItems">
	<xsl:element name="StudyOID"><xsl:value-of select="../../../@OID"/></xsl:element>
	<xsl:element name="ItemGroupOID"><xsl:value-of select="../@OID"/></xsl:element>
	<xsl:element name="ItemGroupName"><xsl:value-of select="../@Name"/></xsl:element>
	<xsl:element name="ItemOID"><xsl:value-of select="@ItemOID"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
      <xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef">
	<xsl:element name="StudyItem">
	<xsl:element name="StudyOID"><xsl:value-of select="../../@OID"/></xsl:element>
	<xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
	<xsl:element name="Name"><xsl:value-of select="@Name"/></xsl:element>
	<xsl:element name="Comment"><xsl:value-of select="@Comment"/></xsl:element>
	<xsl:element name="DataType"><xsl:value-of select="@DataType"/></xsl:element>
	<xsl:element name="Length"><xsl:value-of select="@Length"/></xsl:element>
	<xsl:element name="SignificantDigits"><xsl:value-of select="@SignificantDigits"/></xsl:element>
	<xsl:element name="QuestionMemo"><xsl:value-of select="odm:Question/odm:TranslatedText"/></xsl:element>
	<xsl:element name="CodeListOID"><xsl:value-of select="odm:CodeListRef/@CodeListOID"/></xsl:element>
	<xsl:element name="MultiSelectListID"><xsl:value-of select="OpenClinica:MultiSelectListRef/@MultiSelectListID"/></xsl:element>
	<xsl:element name="MeasurementUnitOID"><xsl:value-of select="odm:MeasurementUnitRef/@MeasurementUnitOID"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
      <xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList/odm:CodeListItem">
	<xsl:element name="StudyCodeListItem">
	<xsl:element name="StudyOID"><xsl:value-of select="../../../@OID"/></xsl:element>
	<xsl:element name="OID"><xsl:value-of select="../@OID"/></xsl:element>
	<xsl:element name="Name"><xsl:value-of select="../@Name"/></xsl:element>
	<xsl:element name="DataType"><xsl:value-of select="../@DataType"/></xsl:element>
	<xsl:element name="CodedValue"><xsl:value-of select="@CodedValue"/></xsl:element>
	<xsl:element name="DecodeValueMemo"><xsl:value-of select="odm:Decode/odm:TranslatedText"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
      <xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/OpenClinica:MultiSelectList/OpenClinica:MultiSelectListItem">
	<xsl:element name="StudyMultiSelectListItem">
	<xsl:element name="StudyOID"><xsl:value-of select="../../../@OID"/></xsl:element>
	<xsl:element name="ID"><xsl:value-of select="../@ID"/></xsl:element>
	<xsl:element name="Name"><xsl:value-of select="../@Name"/></xsl:element>
	<xsl:element name="DataType"><xsl:value-of select="../@DataType"/></xsl:element>
	<xsl:element name="CodedValue"><xsl:value-of select="@CodedOptionValue"/></xsl:element>
	<xsl:element name="DecodeValueMemo"><xsl:value-of select="odm:Decode/odm:TranslatedText"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
      <xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef/odm:RangeCheck">
	<xsl:element name="StudyRangeCheckItem">
	<xsl:element name="StudyOID"><xsl:value-of select="../../../@OID"/></xsl:element>
	<xsl:element name="OID"><xsl:value-of select="../@OID"/></xsl:element>
	<xsl:element name="Comparator"><xsl:value-of select="@Comparator"/></xsl:element>
	<xsl:element name="CheckValue"><xsl:value-of select="odm:CheckValue"/></xsl:element>
	<xsl:element name="ErrorMessage"><xsl:value-of select="odm:ErrorMessage/odm:TranslatedText"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
      <xsl:for-each select="odm:ODM/odm:AdminData/odm:User">
	<xsl:element name="StudyUsers">
	<xsl:element name="StudyOID"><xsl:value-of select="../@StudyOID"/></xsl:element>
	<xsl:element name="OID"><xsl:value-of select="@OID"/></xsl:element>
	<xsl:element name="FullName"><xsl:value-of select="odm:FullName"/></xsl:element>
	<xsl:element name="FirstName"><xsl:value-of select="odm:FirstName"/></xsl:element>
	<xsl:element name="LastName"><xsl:value-of select="odm:LastName"/></xsl:element>
	<xsl:element name="Organization"><xsl:value-of select="odm:Organization"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
	<xsl:for-each select="odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData/odm:ItemData/OpenClinica:DiscrepancyNotes/OpenClinica:DiscrepancyNote">
	<xsl:element name="StudyDataDiscrepancyNotes">
    	<xsl:element name="StudyID"><xsl:value-of select="../../../../../../../@StudyOID"/></xsl:element>
	<xsl:element name="SubjectID"><xsl:value-of select="../../../../../../@OpenClinica:StudySubjectID"/></xsl:element>
	<xsl:element name="StudyEventOID"><xsl:value-of select="../../../../../@StudyEventOID"/></xsl:element>
	<xsl:element name="StudyEventRepeatKey"><xsl:value-of select="../../../../../@StudyEventRepeatKey"/></xsl:element>
	<xsl:element name="FormOID"><xsl:value-of select="../../../../@FormOID"/></xsl:element>
	<xsl:element name="ItemGroupOID"><xsl:value-of select="../../../@ItemGroupOID"/></xsl:element>
	<xsl:element name="ItemGroupRepeatKey"><xsl:value-of select="../../../@ItemGroupRepeatKey"/></xsl:element>
	<xsl:element name="ItemOID"><xsl:value-of select="../../@ItemOID"/></xsl:element>
	<xsl:element name="ID"><xsl:value-of select="@ID"/></xsl:element>
	<xsl:element name="Status"><xsl:value-of select="@Status"/></xsl:element>
	<xsl:element name="NoteType"><xsl:value-of select="@NoteType"/></xsl:element>
	<xsl:element name="DateUpdated"><xsl:value-of select="@DateUpdated"/></xsl:element>
	<xsl:element name="NumberOfUpdates"><xsl:value-of select="@NumberOfChildNotes"/></xsl:element>
	</xsl:element>
      </xsl:for-each>
	<xsl:for-each select="odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData/odm:ItemData/OpenClinica:DiscrepancyNotes/OpenClinica:DiscrepancyNote/OpenClinica:ChildNote">
	<xsl:element name="StudyDataDiscrepancyNoteUpdates">
	<xsl:element name="StudyDataDiscrepancyNoteID"><xsl:value-of select="../@ID"/></xsl:element>
	<xsl:element name="Status"><xsl:value-of select="@Status"/></xsl:element>
	<xsl:element name="DateCreated"><xsl:value-of select="@DateCreated"/></xsl:element>
	<xsl:element name="Description"><xsl:value-of select="OpenClinica:Description"/></xsl:element>
	<xsl:element name="DetailedNote"><xsl:value-of select="OpenClinica:DetailedNote"/></xsl:element>
	<xsl:element name="UserOID"><xsl:value-of select="odm:UserRef/@UserOID"/></xsl:element>
	</xsl:element>
      </xsl:for-each>


<xsl:for-each select="odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData">
<xsl:element name="StudyFormStatus">
<xsl:element name="StudyID"><xsl:value-of select="../../../@StudyOID"/></xsl:element>
<xsl:element name="SubjectID"><xsl:value-of select="../../@OpenClinica:StudySubjectID"/></xsl:element>
<xsl:element name="SubjectKey"><xsl:value-of select="../../@SubjectKey"/></xsl:element>
<xsl:element name="SubjectSecondaryID"><xsl:value-of select="../../@OpenClinica:SecondaryID"/></xsl:element>
<xsl:element name="StudyEventOID"><xsl:value-of select="../@StudyEventOID"/></xsl:element>
<xsl:element name="StudyEventRepeatKey"><xsl:value-of select="../@StudyEventRepeatKey"/></xsl:element>
<xsl:element name="StudyEventStatus"><xsl:value-of select="../@OpenClinica:Status"/></xsl:element>
<xsl:element name="StudyEventStartDate"><xsl:value-of select="../@OpenClinica:StartDate"/></xsl:element>
<xsl:element name="FormOID"><xsl:value-of select="@FormOID"/></xsl:element>
<xsl:element name="FormVersion"><xsl:value-of select="@OpenClinica:Version"/></xsl:element>
<xsl:element name="FormStatus"><xsl:value-of select="@OpenClinica:Status"/></xsl:element>
<xsl:element name="InterviewerName"><xsl:value-of select="@OpenClinica:InterviewerName"/></xsl:element>
<xsl:element name="InterviewDate"><xsl:value-of select="@OpenClinica:InterviewDate"/></xsl:element>
</xsl:element>
</xsl:for-each>
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
    <xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$vitemgrouprefOID]">
     <xsl:variable name="vStudyEventOID"><xsl:value-of select="../../@StudyEventOID"/></xsl:variable>
     <xsl:variable name="vFormOID"><xsl:value-of select="../@FormOID"/></xsl:variable>
     <xsl:element name="{$vTableName}">
      <xsl:element name="SubjectID"><xsl:value-of select="../../../@OpenClinica:StudySubjectID"/>
      </xsl:element>
      <xsl:element name="EventName"><xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:StudyEventDef[@OID=$vStudyEventOID]/@Name"/>
      </xsl:element>
      <xsl:if test="@StudyEventRepeatKey">
       <xsl:element name="StudyEventRepeatKey"><xsl:value-of select="../../@StudyEventRepeatKey"/>
       </xsl:element>
      </xsl:if>
      <xsl:element name="CRFName"><xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:FormDef[@OID=$vFormOID]/@Name"/>
      </xsl:element>
      <xsl:if test="@ItemGroupRepeatKey">
       <xsl:element name="ItemGroupRepeatKey"><xsl:value-of select="@ItemGroupRepeatKey"/>
       </xsl:element>
      </xsl:if>
      <xsl:for-each select="odm:ItemData">
       <xsl:variable name="vItemOID">
        <xsl:value-of select="@ItemOID"/>
       </xsl:variable>
       <xsl:variable name="vItemName">
        <xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vItemOID]/@Name"/>
       </xsl:variable>
       <xsl:variable name="vItemNameClean">
        <xsl:call-template name="replace">
         <xsl:with-param name="text" select="$vItemName" />
         <xsl:with-param name="replace" select="' '" />
         <xsl:with-param name="by" select="''" />
        </xsl:call-template>
       </xsl:variable>
       <xsl:element name="{$vItemNameClean}">
        <xsl:value-of select="@Value"/>
       </xsl:element>
      </xsl:for-each>
     </xsl:element>
    </xsl:for-each>
   </xsl:for-each>


</ODM>
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
     <xsl:with-param name="text" select="substring-after($text,$replace)" />
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
