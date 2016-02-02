<?xml version="1.0" ?>
<xsl:stylesheet 
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
    xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1"
    exclude-result-prefixes="odm OpenClinica">
    <xsl:output indent="yes" encoding="utf-8"/>
    <xsl:strip-space elements="*"/>

    <!-- template to suppress unnecessary Study and AdminData nodes -->
    <xsl:template match="text()"/>

    <!-- lookup lists for matching object details by OID -->
    <xsl:key name="site-name" match="odm:Study" use="@OID"/>
    <xsl:key name="subject-id" match="odm:SubjectData" use="@OID"/>
    <xsl:key name="event-name" match="odm:StudyEventDef" use="@OID"/>
    <xsl:key name="form-name" match="odm:FormDef" use="@OID"/>
    <xsl:key name="form-section" match="OpenClinica:ItemDetails" use="@ItemOID"/>
    <xsl:key name="itemgroup-name" match="odm:ItemGroupDef" use="@OID"/>
    <xsl:key name="item-name" match="odm:ItemDef" use="@OID"/>
    <xsl:key name="code-list" match="odm:CodeList" use="@OID"/>

    <!-- template to return the study node -->
    <xsl:template match="/*">
        <xsl:element name="study">
            <xsl:element name="study_name">
                <xsl:value-of select="odm:Study[position()=1]/
                    odm:GlobalVariables/odm:StudyName"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- template to return the site nodes -->
    <xsl:template match="odm:ClinicalData[descendant::
        OpenClinica:DiscrepancyNotes/OpenClinica:DiscrepancyNote
        [@Status='New' or @Status='Updated']]">
        <xsl:element name="site">
            <xsl:element name="site_name">
                <xsl:value-of select="substring-after(key('site-name', 
                @StudyOID)/odm:GlobalVariables/odm:StudyName,' - ')"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- template to return the subject nodes -->
    <xsl:template match="odm:SubjectData[descendant::
        OpenClinica:DiscrepancyNotes/OpenClinica:DiscrepancyNote
        [@Status='New' or @Status='Updated']]">
        <xsl:element name="subject">
            <xsl:element name="subject_id">
                <xsl:value-of select="@OpenClinica:StudySubjectID"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- template to return the discrepancy note nodes -->
    <xsl:template match="OpenClinica:DiscrepancyNotes/
        OpenClinica:DiscrepancyNote[@Status='New' or @Status='Updated']">
        <xsl:element name="dnote">
            <xsl:element name="dn_id">
                <xsl:value-of select="@ID"/>
            </xsl:element>
            <xsl:element name="dn_status">
                <xsl:value-of select="@Status"/>
            </xsl:element>
            <xsl:element name="dn_description_last">
                <xsl:value-of select="OpenClinica:ChildNote[position
                ()=../@NumberOfChildNotes]/OpenClinica:Description"/>
            </xsl:element>
            <xsl:element name="dn_detailed_note_last">
                <xsl:value-of select="OpenClinica:ChildNote[last()]
                    /OpenClinica:DetailedNote"/>
            </xsl:element>
            <xsl:element name="dn_entity_id">
                <xsl:value-of select="../@EntityID"/>
            </xsl:element>
            <xsl:element name="dn_entity_type">
                <xsl:choose>
                    <xsl:when test="substring(../@EntityID,1,2)='I_'">
                        <xsl:text>Item</xsl:text>
                    </xsl:when>
                    <xsl:when test="substring(../@EntityID,1,2)='F_'">
                        <xsl:text>Form</xsl:text>
                    </xsl:when>
                    <xsl:when test="substring(../@EntityID,1,3)='SE_'">
                        <xsl:text>Event</xsl:text>
                    </xsl:when>
                    <xsl:when test="substring(../@EntityID,1,3)='SS_'">
                        <xsl:text>Subject</xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:element>
            <xsl:element name="dn_entity_detail">
                <xsl:variable name="item-value" select="ancestor::odm:ItemData/@Value"/>
                <xsl:element name="event_name">
                    <xsl:value-of select="key('event-name',ancestor::
                        odm:StudyEventData/@StudyEventOID)/@Name"/>
                </xsl:element>
                <xsl:element name="event_repeat">
                    <xsl:value-of select="ancestor::
                        odm:StudyEventData/@StudyEventRepeatKey"/>
                </xsl:element>
                <xsl:element name="form_name">
                    <xsl:value-of select="key('form-name',ancestor::
                        odm:FormData/@FormOID)/@Name"/>
                </xsl:element>
                <xsl:element name="form_section">
                    <xsl:variable name="form_oid" select="ancestor::
                        odm:FormData/@FormOID"/>
                    <xsl:value-of select="key('form-section',../@EntityID)
                        /OpenClinica:ItemPresentInForm[@FormOID=$form_oid]
                        /OpenClinica:SectionLabel"/>
                </xsl:element>
                <xsl:element name="itemgroup_name">
                    <xsl:value-of select="key('itemgroup-name',ancestor::
                        odm:ItemGroupData/@ItemGroupOID)/@Name"/>
                </xsl:element>
                <xsl:element name="itemgroup_repeat">
                    <xsl:value-of select="ancestor::
                        odm:ItemGroupData/@ItemGroupRepeatKey"/>
                </xsl:element>
                <xsl:element name="item_name">
                    <xsl:value-of select="key('item-name',../@EntityID)
                        /@Comment"/>
                </xsl:element>
                <xsl:element name="item_value">
                    <xsl:value-of select="$item-value"/>
                </xsl:element>
                <xsl:element name="item_code_list_label">
                    <xsl:value-of select="key('code-list',key('item-name',../@EntityID)/odm:CodeListRef/@CodeListOID)/odm:CodeListItem[@CodedValue=$item-value]/odm:Decode/odm:TranslatedText/text()"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>