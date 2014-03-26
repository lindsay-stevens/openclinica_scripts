<?xml version="1.0"?>
<xsl:stylesheet exclude-result-prefixes="x h jr"
                version="2.0"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:jr="http://openrosa.org/javarosa"
                xmlns:x="http://www.w3.org/2002/xforms"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="utf-8"
                indent="yes" />
    <!-- 
        this xsl is for transforming an xform xml into a listing, to
        facilitate clearer documentation and enable tracking review.
        
        it is kind of like the reverse of the xlsform to xml conversion
        in that for each node in the body, the details from the bind
        and translation info are retrieved.
        
        it was written for a form with only one itext language, which
        was only there for the sake of including a few images - the rest of
        the labels were defined in the body.
        
        todo: add a nodeset with all select1 item value/label pairs.
      -->
    <xsl:strip-space elements="*" />
    <!-- 
        template to suppress text() 
      -->
    <xsl:template match="text()" />
    <!-- 
        keys for matching object details by the nodeset string 
      -->
    <xsl:key match="x:bind"
             name="bind-nodeset"
             use="@nodeset" />
    <xsl:key match="x:text"
             name="itext-id"
             use="substring-before(@id,':label')" />
    <!--
        variable with a list of the nodes which are field-lists
      -->
    <xsl:variable name="field-lists"
                  select="tokenize(string-join((//x:group[@appearance='field-list']/tokenize(@ref,'/')[position()=last()]),','),',')" />
    <!-- 
        template to create root form node from body element 
      -->
    <xsl:template match="h:html/h:body">
        <xsl:element name="form">
            <xsl:apply-templates select="//*[@ref]" />
        </xsl:element>
    </xsl:template>
    <!--
        template to add part details from all body child elements excl. labels.
        details are matched to binding and itext info by nodeset string.
        openclinica item and item_group oids generated for 'required' items.
            for the item_group oids, items in a field-list are put one level
            higher, so that they are in the parent section item group (sa-sj)
      -->
    <xsl:template match="//*[@ref and not(local-name()='label')]">
        <xsl:element name="parts">
            <xsl:element name="nodetype">
                <xsl:value-of select="local-name()" />
            </xsl:element>
            <xsl:element name="noderef">
                <xsl:value-of select="@ref" />
            </xsl:element>
            <xsl:element name="label">
                <xsl:value-of select="x:label" />
            </xsl:element>
            <xsl:element name="hint">
                <xsl:value-of select="x:hint" />
            </xsl:element>
            <xsl:element name="itext_long">
                <xsl:value-of select="key('itext-id',@ref)/x:value[@form='long']" />
            </xsl:element>
            <xsl:element name="itext_image">
                <xsl:value-of select="key('itext-id',@ref)/x:value[@form='image']" />
            </xsl:element>
            <xsl:element name="datatype">
                <xsl:value-of select="key('bind-nodeset',@ref)/@type" />
            </xsl:element>
            <xsl:element name="required">
                <xsl:value-of select="key('bind-nodeset',@ref)/@required" />
            </xsl:element>
            <xsl:element name="relevant">
                <xsl:value-of select="key('bind-nodeset',@ref)/@relevant" />
            </xsl:element>
            <xsl:element name="readonly">
                <xsl:value-of select="key('bind-nodeset',@ref)/@readonly" />
            </xsl:element>
            <xsl:element name="constraint">
                <xsl:value-of select="key('bind-nodeset',@ref)/@constraint" />
            </xsl:element>
            <xsl:element name="constraintMsg">
                <xsl:value-of select="key('bind-nodeset',@ref)/@jr:constraintMsg" />
            </xsl:element>
            <xsl:element name="calculate">
                <xsl:value-of select="key('bind-nodeset',@ref)/@calculate" />
            </xsl:element>
            <xsl:element name="preload">
                <xsl:value-of select="key('bind-nodeset',@ref)/@jr:preload" />
            </xsl:element>
            <xsl:element name="preloadParams">
                <xsl:value-of select="key('bind-nodeset',@ref)/@jr:preloadParams" />
            </xsl:element>
            <xsl:element name="appearance">
                <xsl:value-of select="@appearance" />
            </xsl:element>
            <!--
                if the form has an id of 'A1201_ENROL' to match the planned
                crf oid for openclinica, then the 'oid-chunk' variable will
                contain 'A1201', which is used for generating item and
                item group oids for items which will have a value (required)
              -->
            <xsl:variable name="oid-chunk"
                          select="substring-before(tokenize(@ref,'/')[2],'_')" />
            <xsl:element name="item_oid">
                <xsl:if test="key('bind-nodeset',@ref)/@required='true()'">
                    <xsl:value-of select="upper-case(string-join(('I',$oid-chunk,tokenize(@ref,'/')[last()]),'_'))" />
                </xsl:if>
            </xsl:element>
            <xsl:element name="item_group_oid">
                <xsl:if test="key('bind-nodeset',@ref)/@required='true()'">
                    <!--
                        if the second last node is not a field-list node
                        then name the item group with it. if it is a 
                        a field-list node, use the third last node.
                      -->
                    <xsl:if test="not(index-of($field-lists,tokenize(@ref,'/')[position()=(last()-1)]))">
                        <xsl:value-of select="upper-case(string-join(('IG',$oid-chunk,tokenize(@ref,'/')[position()=(last()-1)]),'_'))" />
                    </xsl:if>
                    <xsl:if test="index-of($field-lists,tokenize(@ref,'/')[position()=(last()-1)])">
                        <xsl:value-of select="upper-case(string-join(('IG',$oid-chunk,tokenize(@ref,'/')[position()=(last()-2)]),'_'))" />
                    </xsl:if>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
