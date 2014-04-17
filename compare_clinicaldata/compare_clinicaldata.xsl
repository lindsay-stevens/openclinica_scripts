<?xml version="1.0"?>
<xsl:stylesheet exclude-result-prefixes="odm"
                version="2.0"
                xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="utf-8"
                indent="yes" />
    <xsl:strip-space elements="*" />
    <!-- 
        variable for selecting files to combine, relative to the location
        of the xsl file, for example the current setting would process all
        the myextract xml files in the 'merge' subfolder in the following:
        - mydatafolder
          compare_clinicaldata.xsl
          - merge
            myextract1.xml
            myextract2.xml
            myextract3.xml
            
        commandline usage (all on one line):
        path/to/java -cp path/to/saxon-8.7.jar net.sf.saxon.Transform -o 
        outputfilename.xml -it collate-template compare_clinicaldata.xsl 
      -->
    <xsl:variable name="responses"
                  select="collection('merge?select=*.xml')" />
    <!--
        read files in the above collection, flatten data first then group
      -->
    <xsl:template name="collate-template" match="/">
        <xsl:variable name="flat">
            <xsl:for-each select="$responses">
                <xsl:apply-templates mode="flatten" />
            </xsl:for-each>
        </xsl:variable>
        <xsl:apply-templates mode="group"
                             select="$flat" />
    </xsl:template>
    <!--
        template to make a row for each item value with odm identifiers
      -->
    <xsl:template match="odm:ItemData"
                  mode="flatten">
        <xsl:element name="ClinicalData">
            <xsl:element name="StudyOID">
                <xsl:value-of select="ancestor:: odm:ClinicalData/@StudyOID" />
            </xsl:element>
            <xsl:element name="SubjectKey">
                <xsl:value-of select="ancestor:: odm:SubjectData/@SubjectKey" />
            </xsl:element>
            <xsl:element name="StudyEventOID">
                <xsl:value-of select="ancestor:: odm:StudyEventData/@StudyEventOID" />
            </xsl:element>
            <xsl:element name="StudyEventRepeatKey">
                <xsl:value-of select="ancestor:: odm:StudyEventData/@StudyEventRepeatKey" />
            </xsl:element>
            <xsl:element name="FormOID">
                <xsl:value-of select="ancestor:: odm:FormData/@FormOID" />
            </xsl:element>
            <xsl:element name="ItemGroupOID">
                <xsl:value-of select="ancestor:: odm:ItemGroupData/@ItemGroupOID" />
            </xsl:element>
            <xsl:element name="ItemGroupRepeatKey">
                <xsl:value-of select="ancestor:: odm:ItemGroupData/@ItemGroupRepeatKey" />
            </xsl:element>
            <xsl:element name="ItemOID">
                <xsl:value-of select="@ItemOID" />
            </xsl:element>
            <xsl:element name="Value">
                <xsl:value-of select="@Value" />
            </xsl:element>
            <xsl:element name="CreationDateTime">
                <xsl:value-of select="ancestor:: odm:ODM/@CreationDateTime" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!--
        group across files by odm identifiers, then for each one retain
        the value and put it in a variable named according to the 
        creationdatetime so that these values can be compared for changes
      -->
    <xsl:template match="/"
                  mode="group">
        <xsl:element name="ODM">
            <xsl:for-each-group group-by="concat(StudyOID, '+',SubjectKey, '+',StudyEventOID, '+',StudyEventRepeatKey, '+',FormOID, '+',ItemGroupOID, '+',ItemGroupRepeatKey, '+',ItemOID)"
                                select="ClinicalData">
                <xsl:element name="ClinicalData">
                    <xsl:element name="StudyOID">
                        <xsl:value-of select="StudyOID" />
                    </xsl:element>
                    <xsl:element name="SubjectKey">
                        <xsl:value-of select="SubjectKey" />
                    </xsl:element>
                    <xsl:element name="StudyEventOID">
                        <xsl:value-of select="StudyEventOID" />
                    </xsl:element>
                    <xsl:element name="StudyEventRepeatKey">
                        <xsl:value-of select="StudyEventRepeatKey" />
                    </xsl:element>
                    <xsl:element name="FormOID">
                        <xsl:value-of select="FormOID" />
                    </xsl:element>
                    <xsl:element name="ItemGroupOID">
                        <xsl:value-of select="ItemGroupOID" />
                    </xsl:element>
                    <xsl:element name="ItemGroupRepeatKey">
                        <xsl:value-of select="ItemGroupRepeatKey" />
                    </xsl:element>
                    <xsl:element name="ItemOID">
                        <xsl:value-of select="ItemOID" />
                    </xsl:element>
                    <xsl:for-each select="current-group()">
                        <!-- 
                            valid element names must start with a letter
                            and not have special characters - for example
                            2014-04-31T12:07:17+11:00 is renamed to
                            ValueAt20140310T1207171100
                          -->
                        <xsl:variable name="value-date"
                                      select="string(concat('ValueAt',translate(CreationDateTime,'-:+','')))" />
                        <xsl:element name="{$value-date}">
                            <xsl:value-of select="Value" />
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>