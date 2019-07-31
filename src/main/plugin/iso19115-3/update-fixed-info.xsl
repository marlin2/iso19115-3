<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
  xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
  xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/2.0"
  xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
  xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
  xmlns:dqm="http://standards.iso.org/iso/19157/-2/dqm/1.0"
  xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
  xmlns:gfc="http://standards.iso.org/iso/19110/gfc/1.1"
  xmlns:mcp="http://schemas.aodn.org.au/mcp-3.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:gn-fn-iso19115-3="http://geonetwork-opensource.org/xsl/functions/profiles/iso19115-3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:java="java:org.fao.geonet.util.XslUtil"
  xmlns:mime="java:org.fao.geonet.util.MimeTypeFinder"
  xmlns:gn="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all">

  <xsl:import href="convert/ISO19139/utility/create19115-3Namespaces.xsl"/>

  <xsl:include href="convert/functions.xsl"/>
  <xsl:include href="layout/utility-fn.xsl"/>

  <xsl:variable name="apiSiteUrl" select="substring(/root/env/siteURL, 1, string-length(/root/env/siteURL)-4)"/>

  <xsl:variable name="codelistloc" select="'http://schemas.aodn.org.au/mcp-3.0/codelists.xml'"/>

  <xsl:variable name="mapping" select="document('mcp-equipment/equipmentToDataParamsMapping.xml')"/>

  <!-- The csv layout for each element in the above file is:
                          1)OA_EQUIPMENT_ID,
                          2)OA_EQUIPMENT_LABEL,
                          3)AODN_PLATFORM,
                          4)Platform IRI,
                          5)AODN_INSTRUMENT,
                          6)Instrument IRI,
                          7)AODN_PARAMETER,
                          8)Parameter IRI,
                          9)AODN_UNITS,
                          10)UNITS IRI
        NOTE: can be multiple rows for each equipment keyword -->

  <xsl:variable name="equipThesaurus" select="'geonetwork.thesaurus.register.equipment.urn:marlin.csiro.au:Equipment'"/>

  <xsl:variable name="idcContact" select="document('http://marlin-dev.it.csiro.au/geonetwork/srv/eng/subtemplate?uuid=urn:marlin.csiro.au:person:125_person_organisation')"/>

  <xsl:variable name="editorConfig"
                select="document('layout/config-editor.xml')"/>

  <!-- The default language is also added as gmd:locale
  for multilingual metadata records. -->
  <xsl:variable name="mainLanguage"
                select="/root/*/mdb:defaultLocale/*/lan:language/*/@codeListValue"/>

  <xsl:variable name="isMultilingual"
                select="count(/root/*/mdb:otherLocale[*/lan:language/*/@codeListValue != $mainLanguage]) > 0"/>

  <xsl:variable name="mainLanguageId"
                select="upper-case(java:twoCharLangCode($mainLanguage))"/>

  <xsl:variable name="locales"
                select="/root/*/*/lan:PT_Locale"/>

  <!-- If no metadata linkage exist, build one based on
  the metadata UUID. -->
  <xsl:variable name="createMetadataLinkage"
                select="count(/root/*/mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage/*[normalize-space(.) != '']) = 0"/>


  <xsl:variable name="url" select="/root/env/siteURL"/>
  <xsl:variable name="uuid" select="/root/env/uuid"/>

  <xsl:variable name="metadataIdentifierCodeSpace"
                select="'urn:uuid'"
                as="xs:string"/>

  <xsl:template match="/root">
    <xsl:apply-templates select="mdb:MD_Metadata"/>
  </xsl:template>

  <xsl:template match="mdb:MD_Metadata">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>

      <xsl:call-template name="add-iso19115-3-namespaces"/>

      <!-- Add metadataIdentifier if it doesn't exist
      TODO: only if not harvested -->
      <mdb:metadataIdentifier>
        <mcc:MD_Identifier>
          <!-- authority could be for this GeoNetwork node ?
            <mcc:authority><cit:CI_Citation>etc</cit:CI_Citation></mcc:authority>
          -->
          <mcc:code>
            <gco:CharacterString><xsl:value-of select="/root/env/uuid"/></gco:CharacterString>
          </mcc:code>
          <mcc:codeSpace>
            <gco:CharacterString><xsl:value-of select="$metadataIdentifierCodeSpace"/></gco:CharacterString>
          </mcc:codeSpace>
        </mcc:MD_Identifier>
      </mdb:metadataIdentifier>

  <!--    <xsl:apply-templates select="mdb:metadataIdentifier[
                                    mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString !=
                                    $metadataIdentifierCodeSpace]"/>-->

      <xsl:apply-templates select="mdb:defaultLocale"/>
      <xsl:apply-templates select="mdb:parentMetadata"/>
      <xsl:apply-templates select="mdb:metadataScope"/>
      <!--
      <xsl:apply-templates select="mdb:contact"/>
      -->
      <xsl:choose>
        <!-- If no originator then add current user as originator -->
        <xsl:when test="/root/env/created">
          <mdb:contact>
            <cit:CI_Responsibility>
              <cit:role>
                <cit:CI_RoleCode codeList="{concat($codelistloc,'#CI_RoleCode')}" codeListValue="originator">originator</cit:CI_RoleCode>
              </cit:role>
              <xsl:call-template name="addCurrentUserAsParty"/>
            </cit:CI_Responsibility>
          </mdb:contact>
          <xsl:call-template name="addIDCAsPointOfContact"/>
        </xsl:when>
        <!-- Add current user as processor, then process everything except the 
             existing processor which will be excluded from the output
             document - this is to ensure that only the latest user is
             added as a processor - note: Marlin administrator is excluded from 
             this role -->
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="/root/env/user/details/username!='admin'">
              <!-- marlin admin does not replace a processor -->
              <mdb:contact>
                <cit:CI_Responsibility>
                  <cit:role>
                    <cit:CI_RoleCode codeList="{concat($codelistloc,'#CI_RoleCode')}" codeListValue="processor">processor</cit:CI_RoleCode>
                  </cit:role>
                  <xsl:call-template name="addCurrentUserAsParty"/>
                </cit:CI_Responsibility>
              </mdb:contact>
              <xsl:call-template name="addIDCAsPointOfContact"/>
              <!-- copy any other metadata contacts with the exception of processors and 
                   pointOfContact so we make sure that IDC is point of contact -->
              <xsl:apply-templates select="mdb:contact[not(cit:CI_Responsibility/cit:role/cit:CI_RoleCode='processor' or cit:CI_Responsibility/cit:role/cit:CI_RoleCode='pointOfContact')]"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- marlin admin does not replace a processor, so add IDC and then grab all mdb:contact except pointOfContact -->
              <xsl:call-template name="addIDCAsPointOfContact"/>
              <xsl:apply-templates select="mdb:contact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode!='pointOfContact']"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:variable name="isCreationDateAvailable"
                    select="mdb:dateInfo/*[cit:dateType/*/@codeListValue = 'creation']"/>
      <xsl:variable name="isRevisionDateAvailable"
                    select="mdb:dateInfo/*[cit:dateType/*/@codeListValue = 'revision']"/>

      <!-- Add creation date if it does not exist-->
      <xsl:if test="not($isCreationDateAvailable)">
        <mdb:dateInfo>
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="{concat($codelistloc,'#CI_DateTypeCode')}" codeListValue="creation"/>
            </cit:dateType>
          </cit:CI_Date>
        </mdb:dateInfo>
      </xsl:if>
      <xsl:if test="not($isRevisionDateAvailable)">
        <mdb:dateInfo>
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="{concat($codelistloc,'#CI_DateTypeCode')}" codeListValue="revision"/>
            </cit:dateType>
          </cit:CI_Date>
        </mdb:dateInfo>
      </xsl:if>


      <!-- Preserve date order -->
      <xsl:for-each select="mdb:dateInfo">
        <xsl:variable name="currentDateType" select="*/cit:dateType/*/@codeListValue"/>

        <!-- Update revision date-->
        <xsl:choose>
          <xsl:when test="$currentDateType = 'revision' and /root/env/changeDate">
            <mdb:dateInfo>
              <cit:CI_Date>
                <cit:date>
                  <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
                </cit:date>
                <cit:dateType>
                  <cit:CI_DateTypeCode codeList="{concat($codelistloc,'#CI_DateTypeCode')}" codeListValue="revision"/>
                </cit:dateType>
              </cit:CI_Date>
            </mdb:dateInfo>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>



      <!-- Add metadataStandard if it doesn't exist -->
      <xsl:choose>
        <xsl:when test="not(mdb:metadataStandard)">
          <mdb:metadataStandard>
            <cit:CI_Citation>
              <cit:title>
                <gco:CharacterString>ISO 19115-3:2018</gco:CharacterString>
              </cit:title>
            </cit:CI_Citation>
          </mdb:metadataStandard>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="mdb:metadataStandard"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="mdb:metadataProfile"/>
      <xsl:apply-templates select="mdb:alternativeMetadataReference"/>
      <xsl:apply-templates select="mdb:otherLocale"/>
      <xsl:apply-templates select="mdb:metadataLinkage"/>

      <xsl:variable name="pointOfTruthUrl" select="concat($url, '/metadata/', $uuid)"/>

      <!-- Create metadata linkage only if it does not exist already. -->
      <xsl:if test="$createMetadataLinkage">
        <!-- TODO: This should only be updated for not harvested records ? -->
        <mdb:metadataLinkage>
          <cit:CI_OnlineResource>
            <cit:linkage>
              <!-- TODO: define a URL pattern and use it here -->
              <!-- TODO: URL could be multilingual ? -->
              <gco:CharacterString><xsl:value-of select="$pointOfTruthUrl"/></gco:CharacterString>
            </cit:linkage>
            <!-- TODO: Could be relevant to add description of the
            point of truth for the metadata linkage but this
            needs to be language dependant. -->
            <cit:function>
              <cit:CI_OnLineFunctionCode codeList="{concat($codelistloc,'#CI_OnLineFunctionCode')}"
                                         codeListValue="completeMetadata"/>
            </cit:function>
          </cit:CI_OnlineResource>
        </mdb:metadataLinkage>
      </xsl:if>

      <xsl:apply-templates select="mdb:spatialRepresentationInfo"/>
      <xsl:apply-templates select="mdb:referenceSystemInfo"/>
      <xsl:apply-templates select="mdb:metadataExtensionInfo"/>
      <xsl:apply-templates select="mdb:identificationInfo"/>
      <xsl:apply-templates select="mdb:contentInfo"/>

      <!-- Add/Overwrite data parameters if we have an equipment keyword that matches one in our mapping -->
      <!-- if we have an equipment thesaurus with a match keyword then we process -->

      <xsl:variable name="equipPresent">
       <xsl:for-each select="//mri:descriptiveKeywords/mri:MD_Keywords[normalize-space(mri:thesaurusName/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gcx:Anchor)=$equipThesaurus]/mri:keyword/gcx:Anchor">
        <xsl:element name="dp">
           <xsl:variable name="currentKeyword" select="text()"/>
           <!-- <xsl:message>Automatically created dp from <xsl:value-of select="$currentKeyword"/></xsl:message> -->
           <xsl:for-each select="$mapping/map/equipment">
              <xsl:variable name="tokens" select="tokenize(string(),',')"/>
              <!-- <xsl:message>Checking <xsl:value-of select="$tokens[2]"/></xsl:message> -->
              <xsl:if test="$currentKeyword=$tokens[2]">
                 <!-- <xsl:message>KW MATCHED TOKEN: <xsl:value-of select="$tokens[2]"/></xsl:message> -->
                 <xsl:call-template name="fillOutDataParameters">
 										<xsl:with-param name="tokens" select="$tokens"/> 
                 </xsl:call-template>
              </xsl:if>
           </xsl:for-each>
        </xsl:element>
		   </xsl:for-each>
      </xsl:variable>

      <!-- Now copy the constructed data parameters into the record -->
      <xsl:if test="count($equipPresent/dp/*) > 0">
        <mdb:contentInfo>
          <mrc:MD_CoverageDescription>
            <mrc:attributeDescription gco:nilReason="inapplicable" />
            <mrc:attributeGroup>
              <mrc:MD_AttributeGroup>
                <mrc:contentType>
                  <mrc:MD_CoverageContentTypeCode codeList="concat($codelistloc,'#MD_CoverageContentTypeCode')" codeListValue="physicalMeasurement" />
                </mrc:contentType>
                <xsl:for-each select="$equipPresent/dp/*">
                  <mrc:attribute>
                    <mrc:MD_SampleDimension>
                      <mrc:otherProperty>
                        <gco:Record xsi:type="mcp:DP_DataParameter_PropertyType">
      	                  <xsl:copy-of select="."/>
                        </gco:Record>
                      </mrc:otherProperty>
                    </mrc:MD_SampleDimension>
                  </mrc:attribute>
                </xsl:for-each>
              </mrc:MD_AttributeGroup>
            </mrc:attributeGroup>
          </mrc:MD_CoverageDescription>
        </mdb:contentInfo>
      </xsl:if>

      <xsl:apply-templates select="mdb:distributionInfo"/>
      <xsl:apply-templates select="mdb:dataQualityInfo"/>
      <xsl:apply-templates select="mdb:resourceLineage"/>
      <xsl:apply-templates select="mdb:portrayalCatalogueInfo"/>
      <xsl:apply-templates select="mdb:metadataConstraints"/>
      <xsl:apply-templates select="mdb:applicationSchemaInfo"/>
      <xsl:apply-templates select="mdb:metadataMaintenance"/>
      <xsl:apply-templates select="mdb:acquisitionInformation"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template name="addIDCAsPointOfContact">
    <mdb:contact>
      <cit:CI_Responsibility>
        <cit:role>
          <cit:CI_RoleCode codeList="{concat($codelistloc,'#CI_RoleCode')}" codeListValue="pointOfContact">pointOfContact</cit:CI_RoleCode>
        </cit:role>
        <cit:party xlink:href="local://xml.metadata.get?uuid=urn:marlin.csiro.au:person:125_person_organisation"/>
      </cit:CI_Responsibility>
    </mdb:contact>
  </xsl:template>

	<!-- ================================================================= -->

  <xsl:template name="addCurrentUserAsParty">
    <cit:party>
      <cit:CI_Organisation>
        <cit:name>
          <gco:CharacterString><xsl:value-of select="/root/env/user/details/organisation"/></gco:CharacterString>
        </cit:name>
        <cit:individual>
          <cit:CI_Individual>
            <cit:name>
              <gco:CharacterString><xsl:value-of select="concat(/root/env/user/details/surname,', ',/root/env/user/details/firstname)"/></gco:CharacterString>
            </cit:name>
          </cit:CI_Individual>
        </cit:individual>
      </cit:CI_Organisation>
    </cit:party>
  </xsl:template>

	<!-- ================================================================= -->

  <!-- Update revision date -->
  <xsl:template match="mdb:dateInfo[cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue='lastUpdate']">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="/root/env/changeDate">
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="{concat($codelistloc,'#CI_DateTypeCode')}" codeListValue="lastUpdate"/>
            </cit:dateType>
          </cit:CI_Date>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

	<!-- ================================================================= -->
 
  <xsl:template match="mri:MD_DataIdentification" priority="100">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="mri:citation"/>
      <xsl:apply-templates select="mri:abstract"/>
      <xsl:apply-templates select="mri:purpose"/>
      <xsl:apply-templates select="mri:credit"/>
      <xsl:apply-templates select="mri:status"/>
      <xsl:apply-templates select="mri:pointOfContact"/>
			<!-- If no custodian then copy in a resource contact with
           role custodian, then copy the other resource contact -->
      <xsl:if test="count(mri:pointOfContact/cit:CI_Responsibility/cit:role/cit:CI_RoleCode[@codeListValue='custodian'])=0">
        <mri:pointOfContact>
          <cit:CI_Responsibility>
            <cit:role>
              <cit:CI_RoleCode codeList="{concat($codelistloc,'#CI_RoleCode')}"
                          codeListValue="custodian">custodian</cit:CI_RoleCode>
            </cit:role>
          </cit:CI_Responsibility>
        </mri:pointOfContact>
      </xsl:if>
      <xsl:apply-templates select="mri:spatialRepresentationType"/>
      <xsl:apply-templates select="mri:spatialResolution"/>
      <xsl:apply-templates select="mri:temporalResolution"/>
      <xsl:apply-templates select="mri:topicCategory"/>
      <xsl:apply-templates select="mri:extent"/>
      <xsl:apply-templates select="mri:additionalDocumentation"/> 
      <xsl:apply-templates select="mri:processingLevel"/> 
      <xsl:apply-templates select="mri:resourceMaintenance"/>
      <xsl:apply-templates select="mri:graphicOverview"/>
      <xsl:apply-templates select="mri:resourceFormat"/>
      <xsl:apply-templates select="mri:descriptiveKeywords"/>
      <xsl:apply-templates select="mri:resourceSpecificUsage"/>
      <xsl:apply-templates select="mri:resourceConstraints"/>
      <xsl:apply-templates select="mri:associatedResource"/>
      <xsl:apply-templates select="mri:defaultLocale"/>
      <xsl:apply-templates select="mri:environmentDescription"/>
      <xsl:apply-templates select="mri:supplementalInformation"/> 
    </xsl:copy>
  </xsl:template>

	<!-- ================================================================= -->

  <xsl:template name="fillOutDataParameters">
    <xsl:param name="tokens"/>

      <mcp:DP_DataParameter>
      	<mcp:parameterName>
					<mcp:DP_Term>
						<mcp:term>
							<gco:CharacterString><xsl:value-of select="$tokens[7]"/></gco:CharacterString>
						</mcp:term>
						<mcp:type>
							<mcp:DP_TypeCode codeList="{concat($codelistloc,'#DP_TypeCode')}" codeListValue="longName">longName</mcp:DP_TypeCode>
						</mcp:type>
						<mcp:usedInDataset>
							<gco:Boolean>false</gco:Boolean>
						</mcp:usedInDataset>
            <mcp:vocabularyRelationship>
              <mcp:DP_VocabularyRelationship>
                <mcp:relationshipType>
                  <mcp:DP_RelationshipTypeCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#DP_RelationshipTypeCode" codeListValue="skos:exactmatch">skos:exactmatch</mcp:DP_RelationshipTypeCode>
                </mcp:relationshipType>
                <mcp:vocabularyTermURL>
                  <gco:CharacterString><xsl:value-of select="$tokens[8]"/></gco:CharacterString>
                </mcp:vocabularyTermURL>
                <mcp:vocabularyListURL gco:nilReason="inapplicable"/>
              </mcp:DP_VocabularyRelationship>
            </mcp:vocabularyRelationship>
					</mcp:DP_Term>
			  </mcp:parameterName>
				<mcp:parameterUnits>
					<mcp:DP_Term>
						<mcp:term>
							<gco:CharacterString><xsl:value-of select="$tokens[9]"/></gco:CharacterString>
						</mcp:term>
						<mcp:type>
							<mcp:DP_TypeCode codeList="{concat($codelistloc,'#DP_TypeCode')}" codeListValue="longName">longName</mcp:DP_TypeCode>
						</mcp:type>
						<mcp:usedInDataset>
							<gco:Boolean>false</gco:Boolean>
						</mcp:usedInDataset>
            <mcp:vocabularyRelationship>
              <mcp:DP_VocabularyRelationship>
                <mcp:relationshipType>
                  <mcp:DP_RelationshipTypeCode codeList="{concat($codelistloc,'#DP_RelationshipTypeCode')}" codeListValue="skos:exactmatch">skos:exactmatch</mcp:DP_RelationshipTypeCode>
                </mcp:relationshipType>
                <mcp:vocabularyTermURL>
                  <gco:CharacterString><xsl:value-of select="$tokens[10]"/></gco:CharacterString>
                </mcp:vocabularyTermURL>
                <mcp:vocabularyListURL gco:nilReason="inapplicable"/>
              </mcp:DP_VocabularyRelationship>
            </mcp:vocabularyRelationship>
					</mcp:DP_Term>
				</mcp:parameterUnits>
				<mcp:parameterMinimumValue gco:nilReason="missing">
					<gco:CharacterString/>
				</mcp:parameterMinimumValue>
				<mcp:parameterMaximumValue gco:nilReason="missing">
					<gco:CharacterString/>
				</mcp:parameterMaximumValue>
        <mcp:parameterDeterminationInstrument>
					<mcp:DP_Term>
						<mcp:term>
							<gco:CharacterString><xsl:value-of select="$tokens[5]"/></gco:CharacterString>
						</mcp:term>
						<mcp:type>
							<mcp:DP_TypeCode codeList="{concat($codelistloc,'#DP_TypeCode')}" codeListValue="longName">longName</mcp:DP_TypeCode>
						</mcp:type>
						<mcp:usedInDataset>
							<gco:Boolean>false</gco:Boolean>
						</mcp:usedInDataset>
            <mcp:vocabularyRelationship>
              <mcp:DP_VocabularyRelationship>
                <mcp:relationshipType>
                  <mcp:DP_RelationshipTypeCode codeList="{concat($codelistloc,'#DP_RelationshipTypeCode')}" codeListValue="skos:exactmatch">skos:exactmatch</mcp:DP_RelationshipTypeCode>
                </mcp:relationshipType>
                <mcp:vocabularyTermURL>
                  <gco:CharacterString><xsl:value-of select="$tokens[6]"/></gco:CharacterString>
                </mcp:vocabularyTermURL>
                <mcp:vocabularyListURL gco:nilReason="inapplicable"/>
              </mcp:DP_VocabularyRelationship>
            </mcp:vocabularyRelationship>
					</mcp:DP_Term>
				</mcp:parameterDeterminationInstrument>
        <mcp:platform>
					<mcp:DP_Term>
						<mcp:term>
							<gco:CharacterString><xsl:value-of select="$tokens[3]"/></gco:CharacterString>
						</mcp:term>
						<mcp:type>
							<mcp:DP_TypeCode codeList="{concat($codelistloc,'#DP_TypeCode')}" codeListValue="longName">longName</mcp:DP_TypeCode>
						</mcp:type>
						<mcp:usedInDataset>
							<gco:Boolean>false</gco:Boolean>
						</mcp:usedInDataset>
            <mcp:vocabularyRelationship>
              <mcp:DP_VocabularyRelationship>
                <mcp:relationshipType>
                  <mcp:DP_RelationshipTypeCode codeList="{concat($codelistloc,'#DP_RelationshipTypeCode')}" codeListValue="skos:exactmatch">skos:exactmatch</mcp:DP_RelationshipTypeCode>
                </mcp:relationshipType>
                <mcp:vocabularyTermURL>
                  <gco:CharacterString><xsl:value-of select="$tokens[4]"/></gco:CharacterString>
                </mcp:vocabularyTermURL>
                <mcp:vocabularyListURL gco:nilReason="inapplicable"/>
              </mcp:DP_VocabularyRelationship>
            </mcp:vocabularyRelationship>
					</mcp:DP_Term>
				</mcp:platform>
      </mcp:DP_DataParameter>
  </xsl:template>
	
	<!-- ================================================================= -->

  <xsl:template match="@gml:id">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="gml:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Fix srsName attribute generate CRS:84 (EPSG:4326 with long/lat
    ordering) by default -->
  <xsl:template match="@srsName">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="srsName">
          <xsl:text>CRS:84</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Add required gml attributes if missing -->
  <xsl:template match="gml:Polygon[not(@gml:id) and not(@srsName)]">
    <xsl:copy>
      <xsl:attribute name="gml:id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:attribute name="srsName">
        <xsl:text>urn:x-ogc:def:crs:EPSG:6.6:4326</xsl:text>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="*[gco:CharacterString|lan:PT_FreeText]">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(name() = 'gco:nilReason') and not(name() = 'xsi:type')]"/>

      <!-- Add nileason if text is empty -->
      <xsl:choose>
        <xsl:when test="normalize-space(gco:CharacterString)=''">
          <xsl:attribute name="gco:nilReason">
            <xsl:choose>
              <xsl:when test="@gco:nilReason"><xsl:value-of select="@gco:nilReason"/></xsl:when>
              <xsl:otherwise>missing</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@gco:nilReason!='missing' and normalize-space(gco:CharacterString)!=''">
          <xsl:copy-of select="@gco:nilReason"/>
        </xsl:when>
      </xsl:choose>


      <!-- For multilingual records, for multilingual fields,
       create a gco:CharacterString containing
       the same value as the default language PT_FreeText.
      -->
      <xsl:variable name="element" select="name()"/>


      <xsl:variable name="excluded"
                    select="gn-fn-iso19115-3:isNotMultilingualField(., $editorConfig)"/>
      <xsl:choose>
        <xsl:when test="not($isMultilingual) or
                        $excluded">
          <!-- Copy gco:CharacterString only. PT_FreeText are removed if not multilingual. -->
          <xsl:apply-templates select="gco:CharacterString"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Add xsi:type for multilingual element. -->
          <xsl:attribute name="xsi:type" select="'lan:PT_FreeText_PropertyType'"/>

          <!-- Is the default language value set in a PT_FreeText ? -->
          <xsl:variable name="isInPTFreeText"
                        select="count(lan:PT_FreeText/*/lan:LocalisedCharacterString[
                                            @locale = concat('#', $mainLanguageId)]) = 1"/>


          <xsl:choose>
            <xsl:when test="$isInPTFreeText">
              <!-- Update gco:CharacterString to contains
                   the default language value from the PT_FreeText.
                   PT_FreeText takes priority. -->
              <gco:CharacterString>
                <xsl:value-of select="lan:PT_FreeText/*/lan:LocalisedCharacterString[
                                            @locale = concat('#', $mainLanguageId)]/text()"/>
              </gco:CharacterString>
              <xsl:apply-templates select="lan:PT_FreeText"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- Populate PT_FreeText for default language if not existing. -->
              <xsl:apply-templates select="gco:CharacterString"/>
              <lan:PT_FreeText>
                <lan:textGroup>
                  <lan:LocalisedCharacterString locale="#{$mainLanguageId}">
                    <xsl:value-of select="gco:CharacterString"/>
                  </lan:LocalisedCharacterString>
                </lan:textGroup>

                <xsl:apply-templates select="lan:PT_FreeText/lan:textGroup"/>
              </lan:PT_FreeText>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>


  <!-- codelists: set @codeList path -->
  <xsl:template match="lan:LanguageCode[@codeListValue]" priority="10">
    <lan:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/">
      <xsl:apply-templates select="@*[name(.)!='codeList']"/>
    </lan:LanguageCode>
  </xsl:template>

  <xsl:template match="dqm:*[@codeListValue]" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of select="concat($codelistloc,'#',local-name(.))"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@codeListValue]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of select="concat($codelistloc,'#',local-name(.))"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>


  <!-- Do not allow to expand operatesOn sub-elements
    and constrain users to use uuidref attribute to link
    service metadata to datasets. This will avoid to have
    error on XSD validation.  |mrc:featureCatalogueCitation[@uuidref] -->
  <xsl:template match="srv:operatesOn">
    <xsl:copy>
      <xsl:copy-of select="@uuidref"/>
      <xsl:if test="@uuidref">
        <xsl:choose>
          <xsl:when test="not(string(@xlink:href)) or starts-with(@xlink:href, /root/env/siteURL)">
            <xsl:attribute name="xlink:href">
              <xsl:value-of select="concat(/root/env/siteURL,'csw?service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;outputSchema=http://standards.iso.org/iso/19115/-3/mdb&amp;elementSetName=full&amp;id=',@uuidref)"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="@xlink:href"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:copy>
  </xsl:template>


  <!-- Set local identifier to the first 3 letters of iso code. Locale ids
    are used for multilingual charcterString using #iso2code for referencing.
  -->
  <xsl:template match="mdb:MD_Metadata/*/lan:PT_Locale">
    <xsl:element name="lan:{local-name()}">
      <xsl:variable name="id"
                    select="upper-case(java:twoCharLangCode(lan:language/lan:LanguageCode/@codeListValue))"/>

      <xsl:apply-templates select="@*"/>
      <xsl:if test="normalize-space(@id)='' or normalize-space(@id)!=$id">
        <xsl:attribute name="id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <!-- Apply same changes as above to the lan:LocalisedCharacterString -->
  <xsl:variable name="language" select="//(mdb:defaultLocale|mdb:otherLocale)/lan:PT_Locale" /> <!-- Need list of all locale -->

  <xsl:template match="lan:LocalisedCharacterString">
    <xsl:element name="lan:{local-name()}">
      <xsl:variable name="currentLocale" select="upper-case(replace(normalize-space(@locale), '^#', ''))"/>
      <xsl:variable name="ptLocale" select="$language[upper-case(replace(normalize-space(@id), '^#', '')) = string($currentLocale)]"/>
      <xsl:variable name="id" select="upper-case(java:twoCharLangCode($ptLocale/lan:language/lan:LanguageCode/@codeListValue))"/>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$id != '' and ($currentLocale = '' or @locale != concat('#', $id)) ">
        <xsl:attribute name="locale">
          <xsl:value-of select="concat('#',$id)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <!-- ================================================================= -->
  <!-- Adjust the namespace declaration - In some cases name() is used to get the
    element. The assumption is that the name is in the format of  <ns:element>
    however in some cases it is in the format of <element xmlns=""> so the
    following will convert them back to the expected value. This also corrects the issue
    where the <element xmlns=""> loose the xmlns="" due to the exclude-result-prefixes="#all" -->
  <!-- Note: Only included prefix gml, mds and gco for now. -->
  <!-- TODO: Figure out how to get the namespace prefix via a function so that we don't need to hard code them -->
  <!-- ================================================================= -->

  <xsl:template name="correct_ns_prefix">
    <xsl:param name="element" />
    <xsl:param name="prefix" />
    <xsl:choose>
      <xsl:when test="local-name($element)=name($element) and $prefix != '' ">
        <xsl:element name="{$prefix}:{local-name($element)}">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mdb:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'mdb'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="gco:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gco'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="gml:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gml'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mri:resourceMaintenance[count(mmi:MD_MaintenanceInformation/*)=0]"/>

  <!-- copy everything else as is -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
