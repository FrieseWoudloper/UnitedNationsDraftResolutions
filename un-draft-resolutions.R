library(rvest)

setwd("d:/temp/maptime")

# List all member states
url <- "http://www.un.org/depts/dhl/unms/cms.shtml"
doc <- html(url)
c <- html_nodes(doc, xpath="//table[@id='countryList']/tr/td/ul/li/a")
l <- html_attr(c, "href")
ms <- data.frame(xml_text(c), paste0("http://www.un.org/depts/dhl/unms/", l), stringsAsFactors = FALSE)
colnames(ms) <- c("member_state", "url")

# Determine the hyperlink to the search page for draft resolutions for each member state
for (i in 1:nrow(ms)) { 
    print(ms[i, c("url")])
    if (ms[i, c("member_state")] != "South Sudan") { # Er gaat iets mis met South Sudan, dus dat land sla ik eerst over
        doc <- html(ms[i, c("url")])
        ms[i, c("search")] <- html_attr(html_node(doc, xpath = "//h3[starts-with(., 'Draft Resolutions Sponsored')]/following-sibling::ul/li/a"), "href")                                            
    } else {
        ms[i, c("search")] <- "http://unbisnet.un.org:8080/ipac20/ipac.jsp?&menu=search&aspect=power&npp=50&ipp=20&spp=20&profile=bib&index=.TW&term=%22draft+resolution%22&index=.AW&term=%22South+Sudan%22" # South Sudan alsnog toevoegen
    }
}

# Determine the number of draft resolutions each member state authored or contributed to
for (i in 1:nrow(ms)){ 
    print(ms[i, c("search")])
    doc <- html(ms[i, c("search")])
    ms[i, c("hits")] <- as.numeric(xml_text(html_node(doc, xpath="//a[@class='normalBlackFont2']/b")))
}

# Save output in un-member-states.csv
write.csv(ms, "un-member-states.csv", row.names = FALSE)

# Collect the metadata of draft resolutions authored or contributed to by The Netherlands
draft_resolutions <- data.frame()
author_contributors <- data.frame()
subjects <- data.frame()

u_start <- "http://unbisnet.un.org:8080/ipac20/ipac.jsp?session=144L060TU0895.3025&profile=bib&page="
u_eind <- "&npp=100&group=0&term=%22draft+resolution%22&index=.TW&uindex=&oper=&term=Netherlands&index=.AW&uindex=&aspect=subtab124&menu=search&ri=1&source=~!horizon&1440060414427"

url_start <- "http://unbisnet.un.org:8080/ipac20/ipac.jsp?session=14406507U7SC5.1512&profile=bib&uri=full=3100001~!"
url_eind <- "~!0&ri=1&aspect=subtab124&menu=search&source=~!horizon"

# Determine the number of pages with search results for The Netherlands
hits <- ms[ms$member_state == "Netherlands", c("hits")]
n <- ceiling(hits / 100)

# Loop through each search results page
for (i in 1:n) {
    print(paste("Bezig met verwerken pagina ", i, "...", sep=""))
    u <- paste(u_start, i, u_eind, sep = "")
    d <- html(u)
    
    # Loop through each search result
    for (j in 1:100){
        x <- ((i - 1) * 100) + j
        
        if (x <= hits){
            print(paste("Bezig met verwerken zoekresultaat ", x, "...", sep=""))
            key <- gsub("bkey", "", html_attr(html_nodes(d, xpath = paste0("//a[@class='boldBlackFont1'][starts-with(., '", x, ".')]/../following-sibling::td[1]/table/tr[1]/td/img")), "name"))
            url <- paste(url_start, key, url_eind, sep = "")
            doc <- html(url)
            
            # Read the metadata
            un_document_symbol <- xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'UN Document Symbol:')]/../following-sibling::td[1]"))
            issuing_body_session <- xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Issuing Body / Session:')]/../following-sibling::td[1]"))
            enhanced_title <- paste(xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Enhanced Title:')]/../following-sibling::td[1]/table/tr")), collapse = ", ")
            title <- paste(xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Title:')]/../following-sibling::td[1]/table/tr")), collapse = ", ")
            imprint <- xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Imprint:')]/../following-sibling::td[1]"))
            link_to <- html_attr(html_nodes(doc, xpath = "//a[starts-with(., 'English')]"), "href") 
            description <- paste(xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Description:')]/../following-sibling::td[1]/table/tr")), collapse = ", ")
            notes <- paste(xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Notes:')]/../following-sibling::td[1]/table/tr")), collapse = " ")
            related_document <- paste(xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Related Document:')]/../following-sibling::td[1]/table/tr")), collapse = ", ") 
            agenda_information <- paste(xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Agenda Information:')]/../following-sibling::td[1]/table/tr")), collapse = ", ")
            type_of_material <- paste(xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Type of Material:')]/../following-sibling::td[1]/table/tr")), collapse = ", ")
            distribution <- paste(xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Distribution:')]/../following-sibling::td[1]/table/tr")), collapse = ", ")
            job_number <- paste(xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Job Number:')]/../following-sibling::td[1]/table/tr")), collapse = ", ")
         
            # Set metadata field to NA (= not applicable) if the data is missing
            if (length(un_document_symbol) == 0) {un_document_symbol <- NA}
            if (length(issuing_body_session) == 0) {issuing_body_session <- NA}
            if (length(enhanced_title) == 0) {enhanced_title <- NA}
            if (length(title) == 0) {title <- NA}
            if (length(imprint) > 0) {
                year <- as.numeric(substr(imprint, nchar(imprint) - 3, nchar(imprint)))
            } else {
                imprint <- NA
                year <- NA
            }
            if (length(link_to) == 0) {link_to <- NA}
            if (length(description) == 0) {description <- NA}
            if (length(notes) == 0) {notes <- NA}
            if (length(related_document) == 0) {related_document <- NA}
            if (length(agenda_information) == 0) {agenda_information <- NA}
            if (length(type_of_material) == 0) {type_of_material <- NA}
            if (length(distribution) == 0) {distribution <- NA}
            if (length(job_number) == 0) {job_number <- NA}
            
            # Add row(s) with metadata for specific search result to dataframe with metadata for all draft resolutions 
            # Author/contributers and subjects are saved in a seperate dataframe because there is a 1-to-n relationship with draft resolution.
            draft_resolutions <- rbind(draft_resolutions, data.frame(un_document_symbol, issuing_body_session, enhanced_title, title, imprint, year, description, notes, related_document, agenda_information, type_of_material, distribution, job_number, stringsAsFactors = FALSE))
            author_contributors <- rbind(author_contributors, data.frame(un_document_symbol, xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Author / Contributors:')]/../following-sibling::td[1]/table/tr")), stringsAsFactors = FALSE))
            s <- xml_text(html_nodes(doc, xpath="//td/a[starts-with(., 'Subjects:')]/../following-sibling::td[1]/table/tr"))
            if (length(s) > 0) {subjects <- rbind(subjects, data.frame(un_document_symbol, s, stringsAsFactors = FALSE))}
        }
    } 
}

# Set appropriate column names
colnames(draft_resolutions) <- c("un_document_symbol", "issuing_body_session", "enhanced_title", "title", "imprint", "year", "description", "notes", "related_document", "agenda_information", "type_of_material", "distribution", "job_number")
colnames(author_contributors) <- c("un_document_symbol", "author_contributors")
colnames(subjects) <- c("un_document_symbol", "subject")

# Save output in CSV-files
write.csv(draft_resolutions, "un-draft-resolutions-neth.csv", row.names = FALSE)
write.csv(data.frame(un_document_symbol, author_contributors), "un-draft-resolutions-neth-author-contributors.csv", row.names = FALSE)
write.csv(data.frame(un_document_symbol, subjects), "un-draft-resolutions-neth-subjects.csv", row.names = FALSE)