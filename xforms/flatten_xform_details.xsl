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
        
        syntax:
        java -cp jars/saxon9he.jar net.sf.saxon.Transform -o:xform_details.xml "infile.xml" flatten_xform_details.xsl
      -->
    <xsl:strip-space elements="*" />
    <!-- 
        template to suppress text() 
      -->
    <xsl:template match="text()" />
    <!-- 
        keys for matching object details by the nodeset string or node name
      -->
    <xsl:key match="x:bind"
             name="bind-nodeset"
             use="@nodeset" />
    <xsl:key match="x:text"
             name="itext-id"
             use="substring-before(@id,':label')" />
    <xsl:key match="//x:instance//*"
             name="instance-nodes"
             use="local-name()" />
    <!--
        variables:
        - list of the nodes which are field-lists
        - form id and version id for additional identification of parts
        - count of meta items, used to adjust non-meta position numbers
      -->
    <xsl:variable name="field-lists"
                  select="tokenize(string-join((//x:group[@appearance='field-list']/tokenize(@ref,'/')[position()=last()]),','),',')" />
    <xsl:variable name="form-id"
                  select="//x:instance/*[@id]/@id" />
    <xsl:variable name="form-version"
                  select="//x:instance/*[@version]/@version" />
    <xsl:variable name="meta-item-count"
                  select="count(//x:bind[tokenize(@nodeset,'/')[position()=last()-1]='meta'])" />
    <!-- 
        template to create root form node from body element and apply templates
        meta nodes do not appear in the body, so must be selected separately
        label nodes are excluded as they are unbound properties of other nodes
      -->
    <xsl:template match="h:html/h:body">
        <xsl:element name="form">
            <xsl:apply-templates mode="metadata"
                                 select="//x:bind[contains(@nodeset,'meta')]" />
            <xsl:apply-templates mode="metadata"
                                 select="//*[@ref and not(local-name()='label')]" />
        </xsl:element>
    </xsl:template>
    <!--
        template to add part details from all body child elements excl. labels.
        details are matched to binding and itext info by nodeset string.
        openclinica item and item_group oids generated for 'required' items.
            for the item_group oids, items in a field-list are put one level
            higher, so that they are in the parent section item group
      -->
    <xsl:template match="*"
                  mode="metadata">
        <xsl:variable name="nodeRef">
            <xsl:choose>
                <xsl:when test="@ref">
                    <xsl:value-of select="@ref" />
                </xsl:when>
                <xsl:when test="@nodeset">
                    <xsl:value-of select="@nodeset" />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nodeName"
                      select="tokenize($nodeRef,'/')[position()=last()]" />
        <xsl:variable name="nodeParent"
                      select="tokenize($nodeRef,'/')[position()=last()-1]" />
        <xsl:element name="parts">
            <xsl:element name="form_id">
                <xsl:value-of select="$form-id" />
            </xsl:element>
            <xsl:element name="form_version">
                <xsl:value-of select="$form-version" />
            </xsl:element>
            <xsl:element name="instanceNodeType">
                <xsl:value-of select="key('instance-nodes',$nodeName)/@nodeType" />
            </xsl:element>
            <xsl:element name="instanceNodeName">
                <xsl:value-of select="$nodeName" />
            </xsl:element>
            <xsl:element name="instanceNodeDescription">
                <xsl:value-of select="key('instance-nodes',$nodeName)/@description" />
            </xsl:element>
            <xsl:element name="noderef">
                <xsl:value-of select="$nodeRef" />
            </xsl:element>
            <xsl:choose>
                <xsl:when test="$nodeParent='meta'">
                    <xsl:element name="nodeposition">
                        <xsl:value-of select="position()" />
                    </xsl:element>
                    <xsl:element name="nodetype">
                        <xsl:value-of select="'meta'" />
                    </xsl:element>
                </xsl:when>
                <xsl:when test="not($nodeParent='meta')">
                    <xsl:element name="nodeposition">
                        <xsl:value-of select="position()+$meta-item-count" />
                    </xsl:element>
                    <xsl:element name="nodetype">
                        <xsl:value-of select="local-name()" />
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            <xsl:element name="label">
                <xsl:value-of select="x:label" />
            </xsl:element>
            <xsl:element name="hint">
                <xsl:value-of select="x:hint" />
            </xsl:element>
            <xsl:element name="itext_long">
                <xsl:value-of select="key('itext-id',$nodeRef)/x:value[@form='long']" />
            </xsl:element>
            <xsl:element name="itext_image">
                <xsl:value-of select="key('itext-id',$nodeRef)/x:value[@form='image']" />
            </xsl:element>
            <xsl:element name="datatype">
                <xsl:value-of select="key('bind-nodeset',$nodeRef)/@type" />
            </xsl:element>
            <xsl:element name="required">
                <xsl:value-of select="key('bind-nodeset',$nodeRef)/@required" />
            </xsl:element>
            <xsl:element name="relevant">
                <xsl:value-of select="key('bind-nodeset',$nodeRef)/@relevant" />
            </xsl:element>
            <xsl:element name="readonly">
                <xsl:value-of select="key('bind-nodeset',$nodeRef)/@readonly" />
            </xsl:element>
            <xsl:element name="constraint">
                <xsl:value-of select="key('bind-nodeset',$nodeRef)/@constraint" />
            </xsl:element>
            <xsl:element name="constraintMsg">
                <xsl:value-of select="key('bind-nodeset',$nodeRef)/@jr:constraintMsg" />
            </xsl:element>
            <xsl:element name="calculate">
                <xsl:value-of select="key('bind-nodeset',$nodeRef)/@calculate" />
            </xsl:element>
            <xsl:element name="preload">
                <xsl:value-of select="key('bind-nodeset',$nodeRef)/@jr:preload" />
            </xsl:element>
            <xsl:element name="preloadParams">
                <xsl:value-of select="key('bind-nodeset',$nodeRef)/@jr:preloadParams" />
            </xsl:element>
            <xsl:element name="appearance">
                <xsl:value-of select="@appearance" />
            </xsl:element>
            <!--
                if the item is data, add a string with the value/label pairs
                and an element tree with the noderef repeated for joining on
              -->
            <xsl:if test="key('instance-nodes',$nodeName)/@nodeType='data'">
                <xsl:element name="select_items_json">
                    <xsl:apply-templates mode="json"
                                         select="x:item" />
                </xsl:element>
                <xsl:element name="select_items_node">
                    <xsl:for-each select="x:item">
                        <xsl:element name="item">
                            <xsl:element name="item_noderef">
                                <xsl:value-of select="../$nodeRef" />
                            </xsl:element>
                            <xsl:element name="item_value">
                                <xsl:value-of select="x:value" />
                            </xsl:element>
                            <xsl:element name="item_label">
                                <xsl:value-of select="x:label" />
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
            <!--
                if the item is data, add expected OpenClinica item_oid and
                item_group_oid, as well as fields formatted for copy/paste
                to an OpenClinica CRF template: item_name, description_label,
                group_label, response_type, response_options_text, 
                response_values_or_calculations, data_type.
              -->
            <xsl:if test="key('instance-nodes',$nodeName)/@nodeType='data'">
                <xsl:variable name="oid-chunk"
                              select="substring-before(tokenize($nodeRef,'/')[2],'_')" />
                <xsl:variable name="item-group-chunk-1"
                              select="$nodeParent" />
                <xsl:variable name="item-group-chunk-2"
                              select="tokenize($nodeRef,'/')[position()=(last()-2)]" />
                <xsl:element name="item_oid">
                    <xsl:value-of select="upper-case(string-join(('I',$oid-chunk,$nodeName),'_'))" />
                </xsl:element>
                <xsl:element name="item_group_oid">
                    <!--
                        if the second last node is not a field-list node
                        then name the item group with it. if it is a 
                        a field-list node, use the third last node.
                      -->
                    <xsl:if test="not(index-of($field-lists,$item-group-chunk-1))">
                        <xsl:value-of select="upper-case(string-join(('IG',$oid-chunk,$item-group-chunk-1),'_'))" />
                    </xsl:if>
                    <xsl:if test="index-of($field-lists,$item-group-chunk-1)">
                        <xsl:value-of select="upper-case(string-join(('IG',$oid-chunk,$item-group-chunk-2),'_'))" />
                    </xsl:if>
                </xsl:element>
                <xsl:element name="item_name">
                    <xsl:value-of select="upper-case($nodeName)" />
                </xsl:element>
                <xsl:element name="description_label">
                    <xsl:value-of select="key('instance-nodes',$nodeName)/@description" />
                </xsl:element>
                <xsl:element name="group_label">
                    <xsl:if test="not(index-of($field-lists,$item-group-chunk-1))">
                        <xsl:value-of select="upper-case($item-group-chunk-1)" />
                    </xsl:if>
                    <xsl:if test="index-of($field-lists,$item-group-chunk-1)">
                        <xsl:value-of select="upper-case($item-group-chunk-2)" />
                    </xsl:if>
                </xsl:element>
                <xsl:element name="response_type">
                    <xsl:choose>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='select1'">
                            <xsl:value-of select="'single-select'" />
                        </xsl:when>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='string'">
                            <xsl:value-of select="'textarea'" />
                        </xsl:when>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='date'">
                            <xsl:value-of select="'text'" />
                        </xsl:when>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='dateTime'">
                            <xsl:value-of select="'text'" />
                        </xsl:when>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='int'">
                            <xsl:value-of select="'text'" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
                <xsl:element name="response_options_text">
                    <xsl:apply-templates mode="csv-labels"
                                         select="x:item" />
                </xsl:element>
                <xsl:element name="response_values_or_calculations">
                    <xsl:apply-templates mode="csv-values"
                                         select="x:item" />
                </xsl:element>
                <xsl:element name="data_type">
                    <xsl:choose>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='select1'">
                            <xsl:value-of select="'INT'" />
                        </xsl:when>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='string'">
                            <xsl:value-of select="'ST'" />
                        </xsl:when>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='date'">
                            <xsl:value-of select="'DATE'" />
                        </xsl:when>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='dateTime'">
                            <xsl:value-of select="'ST'" />
                        </xsl:when>
                        <xsl:when test="key('bind-nodeset',$nodeRef)/@type='int'">
                            <xsl:value-of select="'INT'" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <!-- 
        template returns a json string of the item value/label pairs
      -->
    <xsl:template match="x:item"
                  mode="json">
        <xsl:value-of select="concat('{&quot;value&quot;:&quot;',x:value,'&quot;,&quot;label&quot;:&quot;',x:label,'&quot;}')" />
        <xsl:if test="not(position()=last())">
            <xsl:value-of select="','" />
        </xsl:if>
    </xsl:template>
    <!-- 
        template returns a csv string of the item values
      -->
    <xsl:template match="x:item"
                  mode="csv-values">
        <xsl:value-of select="x:value" />
        <xsl:if test="not(position()=last())">
            <xsl:value-of select="','" />
        </xsl:if>
    </xsl:template>
    <!-- 
        template returns a csv string of the item labels
      -->
    <xsl:template match="x:item"
                  mode="csv-labels">
        <xsl:value-of select="replace(x:label,',','\\\\,')" />
        <xsl:if test="not(position()=last())">
            <xsl:value-of select="','" />
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
