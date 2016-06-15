<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:include href="header.xsl" />
<xsl:include href="senderReceiver.xsl" />
<xsl:include href="mailReason.xsl" />
<xsl:include href="footer.xsl" />
<xsl:include href="style.xsl" />
<xsl:include href="recordTitle.xsl" />

<xsl:template match="/">
 <html>
  <head>
   <xsl:call-template name="generalStyle" />

   <!-- DM 2016-01-13: Skriver ut libnummer i footer hvis mottaker er et bibliotek, slik
        at lappen også kan tjene som sendelapp.
        Ref.: https://trello.com/c/zNBDgUdg/5-pickup-from-shelf-lagt-inn-advarsel-obs-mottaker-er-et-bibliotek-pass-pa-at-dokumentet-ikke-havner-pa-hentehylla-hvis-mottaker-h
   -->
   <xsl:if test="contains(notification_data/user_for_printing/identifiers/code_value[1]/value, 'lib')">
    <xsl:element name="meta">
     <xsl:attribute name="name">libnummer</xsl:attribute>
     <xsl:attribute name="content">
      <xsl:value-of select="substring(notification_data/user_for_printing/identifiers/code_value[1]/value, 4, 3)"/>&#160;&#160;<xsl:value-of select="substring(notification_data/user_for_printing/identifiers/code_value[1]/value, 7, 4)"/>
     </xsl:attribute>
    </xsl:element>
   </xsl:if>
   <!-- SLUTT: DM 2016-01-13 -->

  </head>

   <body>

    <table width="100%">
    <tr>
     <xsl:choose>

      <xsl:when test="notification_data/request/work_flow_entity/step_type = 'ON_HOLD_SHELF'">
        <!-- ===========================================================
             START: Hentehylle
             =========================================================== -->
        <td>
          <xsl:choose>

            <xsl:when test="notification_data/request/calculated_destination_name = 'UiO HumSam-biblioteket - HumSam-biblioteket-Innlån' or notification_data/request/calculated_destination_name = 'UiO Informatikkbiblioteket - Utlånet Inf' or contains(notification_data/phys_item_display/available_items/available_item/location_name, 'Fjernlån')">
              <font size="7"><b>
                <xsl:value-of select="notification_data/user_for_printing/name"/>
              </b></font>
            </xsl:when>

            <xsl:when test="contains(notification_data/user_for_printing/identifiers/code_value[1]/value, 'lib')">
              <!-- Nothing -->
            </xsl:when>

            <xsl:otherwise>

              <!-- Hentenummer konstruert av hentefrist, siste tre siffer i LTID og to siffer fra selected_inventory_id -->
              <!-- Merk: html2ps støtter font size > 7, så 12 blir faktisk større enn 7. -->
              <font size="12"><b>
                <xsl:call-template name="pickupNumber"/><!-- mailReason.xsl -->
              </b></font>

            </xsl:otherwise>

          </xsl:choose>
        </td>
        <!-- ===========================================================
             SLUTT: Hentehylle
             =========================================================== -->

      </xsl:when>

      <xsl:otherwise>
       <td>
        <h2>
         <xsl:choose>
          <xsl:when test="notification_data/request/work_flow_entity/step_type = 'PICKUP_FROM_SHELF'">
            Pickup From Shelf
          </xsl:when>
          <xsl:otherwise>
            Resource Request
          </xsl:otherwise>
         </xsl:choose>
        </h2>
       </td>
       <td align="right" valign="top">
        <tt>
         <xsl:call-template name="normalizedDate"><!-- header.xsl -->
                    <xsl:with-param name="value" select="notification_data/request/create_date"/>
                  </xsl:call-template>
                  &#160;<xsl:value-of select="notification_data/request/create_time"/>
        </tt>
       </td>
      </xsl:otherwise>
     </xsl:choose>
    </tr>
     <!-- Hvis man skulle ønsker å teste på om boken skal sendes eller ikke:
      <xsl:if test="notification_data/destination = notification_data/organization_unit/name">
     -->
   </table>
<!--
    <xsl:call-template name="head" />
-->


   <div class="messageArea">
    <div class="messageBody">

     <table cellspacing="0" cellpadding="5" border="0" width="100%">


      <!-- S1: Infotekst til hentehyllelapp -->
      <xsl:if test="notification_data/request/work_flow_entity/step_type = 'ON_HOLD_SHELF'">
        <!-- Skulle gjerne testet språk, men det finnes ikke i XML-en -->
        <!--
        <xsl:choose>
         <xsl:when test="notification_data/receivers/receiver/preferred_language = 'no'">
          <h1>Til henting</h1>
          <h2>Lån ut eksemplaret til Dem selv på automaten</h2>
         </xsl:when>
        <xsl:otherwise>
         <h1>For pick-up</h1>
         <h2>Please check out the item on the machine</h2>
        </xsl:otherwise>
       </xsl:choose>
       -->
       <h1>Til henting / for pick-up</h1>
       <h2><ul>
        <li>Lån ut eksemplaret til Dem selv på automaten</li>
        <li>Please check out the item on the machine</li>
       </ul></h2>
       <hr/>
      </xsl:if>
      <!-- S1: SLUTT -->


       <!-- S2: Strekkoder, etc. Skjules for hentehylleseddel -->
      <xsl:if test="notification_data/request/work_flow_entity/step_type != 'ON_HOLD_SHELF'">
       <xsl:if  test="notification_data/request/selected_inventory_type='ITEM'" >
       <tr>
        <td></td>
        <td><b>@@note_item_specified_request@@.</b></td>
       </tr>
       </xsl:if>
       <tr>
        <td valign="top" colspan="2" align="center">
         <font size="2">@@request_id@@:</font><br/>
         <img src="cid:request_id_barcode.png" alt="Request Barcode"/>
        </td>
       </tr>
       <xsl:if test="notification_data/request/selected_inventory_type='ITEM'" >
       <tr>
        <td valign="top" colspan="2" align="center">
         <font size="2">@@item_barcode@@:</font><br/>
         <img src="cid:item_id_barcode.png" alt="Item Barcode"/>
        </td>
       </tr>
       </xsl:if>
      </xsl:if>
      <!-- S2: SLUTT -->


      <!-- Horizontal line -->
      <tr><td colspan="2"><hr/></td></tr>


      <!-- S3: Grunnleggende metadata: tittel/forfatter m.m. Vises uansett brevtype-->
      <tr>
       <td>Title:</td>
       <td>
        <xsl:value-of select="notification_data/phys_item_display/title_abcnph"/>
       </td>
      </tr>
      <tr>
       <td>By:</td>
       <td>
        <xsl:value-of select="notification_data/phys_item_display/author"/>
       </td>
      </tr>
      <xsl:if test="notification_data/phys_item_display/isbn != ''">
       <tr>
        <td>@@isbn@@:</td>
        <td>
         <xsl:value-of select="notification_data/phys_item_display/isbn"/>
        </td>
       </tr>
      </xsl:if>
      <xsl:if test="notification_data/phys_item_display/issn != ''">
       <tr>
        <td>@@issn@@:</td>
        <td>
         <xsl:value-of select="notification_data/phys_item_display/issn"/>
        </td>
       </tr>
      </xsl:if>
      <tr>
       <td>Edition/year:</td>
       <td>
        <xsl:value-of select="notification_data/phys_item_display/edition"/>
        <xsl:if test="notification_data/phys_item_display/edition != ''">
         &#160;
        </xsl:if>
        <xsl:value-of select="notification_data/phys_item_display/publication_date"/>
       </td>
      </tr>
      <xsl:if test="notification_data/phys_item_display/issue_level_description != ''">
       <tr>
        <td>Issue:</td>
        <td>
         <xsl:value-of select="notification_data/phys_item_display/issue_level_description"/>
        </td>
       </tr>
      </xsl:if>
      <xsl:if test="notification_data/request/record_display_section/series_small != ''" >
       <tr>
        <td>Series:</td>
        <td>
         <xsl:value-of select="notification_data/request/record_display_section/series_small"/>
        </td>
       </tr>
      </xsl:if>
      <xsl:if  test="notification_data/request/manual_description != ''" >
       <tr>
        <td>
         <em>Description: </em>
        </td>
        <td>
         <b>
          <xsl:value-of select="notification_data/request/manual_description"/>
         </b>
        </td>
       </tr>
      </xsl:if>
      <!--
      <xsl:if test="notification_data/phys_item_display/imprint != ''">
       <tr>
       <td>@@imprint@@: <xsl:value-of select="notification_data/phys_item_display/imprint"/></td>
       </tr>
      </xsl:if>
      <xsl:if test="notification_data/phys_item_display/edition != ''">
       <tr>
       <td>@@edition@@: <xsl:value-of select="notification_data/phys_item_display/edition"/></td>
       </tr>
      </xsl:if>
     -->
     <!-- S3: SLUTT -->

     <!-- S4: Skjules for hentehylleseddel -->
     <xsl:if test="notification_data/request/work_flow_entity/step_type != 'ON_HOLD_SHELF'">


      <!-- Horizontal line -->
      <tr><td colspan="2"><hr/></td></tr>


      <!-- Destination, request type, notes -->
      <tr>
       <td>@@request_type@@:</td>
       <td>
        <xsl:value-of select="notification_data/request_type"/>
        (<xsl:value-of select="notification_data/request/request_type"/>)
       </td>
      </tr>
      <xsl:if test="notification_data/user_for_printing/name">
       <tr>
        <td valign="top">
         @@requested_for@@:
        </td>
        <td>
         <xsl:value-of select="notification_data/user_for_printing/identifiers/code_value[1]/value"/>
         :
         <xsl:value-of select="notification_data/user_for_printing/name"/>

         <!-- Reference: user_group

          │1  Egne studenter                     15. Nasjonalbiblioteket               │
          │2  Egne studenter - høyere grad       16. Folkebiblioteksektoren            │
          │3  Egne fjernstudenter                17. Bibl. i grunn-/videregående skole │
          │4  Egne ansatte                       18.-19. Ikke i bruk                   │
          │5  Ekst. stipendiater egen inst.      20. Bibliotek og lign.inst. i Danmark │
          │6  Stud./stip./ans. andre utd.inst -  21. Bibliotek og lign.inst. i Sverige │
          │7  Enkeltpersoner                     22. Bibliotek og lign.inst. i Finland │
          │8  Bedrifter/inst. uten bibliotek     23. Bibliotek og lign.inst. i Island  │
          │9  Ikke i bruk                        24. Øvrige Europeiske bibliotek       │
          │10 Andre bibenheter innen samme inst. 25. Verden ellers                     │
          │11 Universitetsbibliotek i Norge      50. Bokbinder                         │
          │12 Høgskolebibliotek i Norge                                                │
          │13 Bedriftsbibliotek i Norge          55-99 Internt bruk v/bibliotekenheten │
          │14 Andre fag- og forskningsbibliotek                                        │
            └──────────────────────────────────────────────────────────────
         -->
         <xsl:if test="notification_data/request/user_group = '4'">
           <h1>(egne ansatte)</h1>
         </xsl:if>
        </td>
       </tr>
      </xsl:if>
      <xsl:if  test="notification_data/user_for_printing/email != ''" >
       <tr>
        <td valign="top">
         @@email@@:
        </td>
        <td>
         <xsl:value-of select="notification_data/user_for_printing/email"/>
        </td>
       </tr>
      </xsl:if>
      <xsl:if  test="notification_data/external_id != ''" >
       <tr>
        <td valign="top">
         @@external_id@@:
        </td>
        <td>
         <xsl:value-of select="notification_data/external_id"/>
        </td>
       </tr>
      </xsl:if>
      <tr>
       <td>@@move_to_library@@:</td>
       <td>
        <xsl:value-of select="notification_data/destination"/>
       </td>
      </tr>
      <xsl:if test="notification_data/request/system_notes != ''">
       <tr>
        <td>@@system_notes@@:</td>
        <td>
         <xsl:value-of select="notification_data/request/system_notes"/>
        </td>
       </tr>
      </xsl:if>
      <xsl:if test="notification_data/request/note != ''">
       <tr>
        <td><em>@@request_note@@:</em></td>
        <td>
         <b>
          <xsl:value-of select="notification_data/request/note"/>
         </b>
        </td>
       </tr>
      </xsl:if>


      <!-- Horizontal line -->
      <tr><td colspan="2"><hr/></td></tr>


      <!-- Physical location: Hvor man finner den der boka... -->
      <!-- Informasjonen er av og til misvisende. Det virker som den viser holding boka er bestilt på, uavhengig av hvilken holding som faktisk har ledige items. Eks: Bok bestilt på pensum, men ledig i boksamling - viser fortsatt pensum.. Så det virker 
      bedre å baserer seg på available_items  (under). Litt usikker på om vi burde ha en test på aksede bøker og andre spesialtilfeller...
      -->

      <!-- ITEM -->
      <xsl:if  test="notification_data/request/selected_inventory_type='ITEM'" >
        <tr>
          <td>
            @@shelving_location_for_item@@:
          </td>
          <td>
            <xsl:choose>
              <xsl:when test="notification_data/phys_item_display/shelving_location/string != ''">
                <xsl:value-of select="notification_data/phys_item_display/shelving_location/string"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="notification_data/phys_item_display/barcode"/> :
                <xsl:value-of select="notification_data/phys_item_display/library_name"/>&#160;
                <xsl:value-of select="notification_data/phys_item_display/location_name"/>&#160;
                <xsl:value-of select="notification_data/phys_item_display/call_number"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </xsl:if>

      <tr><td colspan="2">

       <xsl:if test="notification_data/request/selected_inventory_type='VIRTUAL_HOLDING'" >
        <p>
         @@shelving_locations_for_holding@@:
        </p>
        <p>
         <xsl:for-each select="notification_data/phys_item_display/shelving_location/string">
          <xsl:value-of select="."/>
          </xsl:for-each>
         </p>
       </xsl:if>

       <!-- DMOH 2016-01-04: Viser barcode for available items -->
       <xsl:if test="notification_data/request/selected_inventory_type='HOLDING' or notification_data/request/selected_inventory_type='VIRTUAL_HOLDING'" >
        <xsl:if test="count(notification_data/phys_item_display/available_items/available_item[library_code=/notification_data/organization_unit/code]) != 0">
         <p>
          Available item(s):
         </p>
         <table>
          <xsl:for-each select="notification_data/phys_item_display/available_items/available_item[library_code=/notification_data/organization_unit/code]">
           <tr>
            <td>
             <font size="4"><xsl:value-of select="barcode"/></font>
            </td>
            <td>
             <font size="4"><xsl:value-of select="location_name"/></font>
            </td>
            <td>
             <u><font size="4"><xsl:value-of select="call_number"/></font></u>
            </td>
            <td>
             <xsl:value-of select="public_note"/>
            </td>
           </tr>
           </xsl:for-each>
         </table>
        </xsl:if>
         <xsl:if test="count(notification_data/phys_item_display/available_items/available_item[library_code=/notification_data/organization_unit/code]) = 0">
          <p>
           <strong>
             <xsl:value-of select="notification_data/phys_item_display/location_name"/>
           <xsl:if test="notification_data/phys_item_display/call_number != ''">
            &#160;<xsl:value-of select="notification_data/phys_item_display/call_number"/>
           </xsl:if>
           <xsl:if test="notification_data/phys_item_display/accession_number != ''">
            &#160; - @@accession_number@@:
            <xsl:value-of select="notification_data/phys_item_display/accession_number"/>
           </xsl:if>
          </strong>

          <xsl:for-each select="notification_data/phys_item_display/summary_holding_infos/summary_holding_info">
           <span>
             &#160;&#160;
             <xsl:value-of select="summary_holding"/>
             &#160;
             <xsl:value-of select="notes/string"/>
            </span>
          </xsl:for-each>
          </p>
         </xsl:if>
       </xsl:if>
       <!-- DMOH 2016-01-04 SLUTT -->
      </td></tr>

     </xsl:if>
     <!-- S4: SLUTT -->

     <tr><td colspan="2">

      <!-- ALERT1: Dokumentet skal sendes til folkebibliotek. Denne seddelen fungerer som sendeseddel. -->
      <xsl:if test="contains(notification_data/user_for_printing/identifiers/code_value[1]/value, 'lib')">
        <hr/>
        <h4>Bestilling fra bibliotek utenfor Bibsys</h4>
       <p>
        <strong>
          Neste steg:
        </strong>
        <em>
          Dokumentet skal til et bibliotek utenfor Bibsys. Bruk "Scan In" for å låne ut dokumentet.
          Som sendeseddel brukes denne seddelen.
        </em>
        <hr/>
       </p>
      </xsl:if>
      <!-- ALERT1: END -->

      <!-- ALERT2: Dokumentet skal sendes til bestillende bibliotek (lending request). Denne seddelen fungerer ikke som sendeseddel. -->
      <xsl:if test="notification_data/request/request_type = 'RESOURCE_SHARING_PHYSICAL_SHIPMENT'">
        <hr/>
        <h4>Bestilling fra annet Bibsys-bibliotek</h4>
       <p>
        <strong>
          Neste steg:
        </strong>
        <em>
          Bruk "Shipping Items" for å få sendeseddel. Husk å krysse av for "Automatically print slip".
        </em>
        <hr/>
       </p>
      </xsl:if>
      <!-- ALERT2: END -->

     </td></tr>
    </table>

    </div>
   </div>


   <!-- Footer til hentehyllelapp -->
   <!--

   <xsl:if test="notification_data/request/work_flow_entity/step_type = 'ON_HOLD_SHELF'">
    <xsl:call-template name="lastFooter" />
   </xsl:if>
  -->

  <!-- SLUTT Footer til hentehyllelapp -->


</body>
</html>


 </xsl:template>
</xsl:stylesheet>