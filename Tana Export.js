{
  "translatorID": "dda092d2-a257-46af-b9a3-2f04a55cb04h",
    "translatorType": 2,
      "label": "Tana Metadata Export",
        "creator": "Stefano Pagliari based on Eneko Uruñuela based on CortexFutura based on Stian Haklev's, Joel Chan's, and Joshua Hall's work",
          "editedBy": "Stefano Pagliari",
            "target": "md",
              "minVersion": "2.0",
                "maxVersion": "",
                  "priority": 200,
                    "inRepository": false,
                      "lastUpdated": "2023-02-28 - 19:51"
}
function doExport() {
	Zotero.write('%%tana%%\n');
	var item;
	while (item = Zotero.nextItem()) {
  
	  // Identify the combined authors name (e.g. Surname, Surname et al.)
	  let combinedCreators = '';
	  const authorKey = [];
	  const editorKey = [];
	  let authorKeyFixed = "";
	  let editorKeyFixed = "";
  
	  for (let creator of item.creators) {
		if (creator.creatorType === "author") {
		  if (creator.name) {
			authorKey.push(creator.name);
		}  else if (creator.lastName) {
			authorKey.push(creator.lastName);
		  } else if (creator.firstName) {
			authorKey.push(creator.firstName);
		  }
		} else if (creator.creatorType === "editor") {
		  if (creator.name) {
			editorKey.push(creator.name);
		  } else if (creator.lastName) {
			editorKey.push(creator.lastName);
		  } else if (creator.firstName) {
			editorKey.push(creator.firstName);
		  }
		}
	  }
  
	  // Adjust the authorKey depending on the number of authors
	  if (authorKey.length == 1) {
		authorKeyFixed = authorKey[0];
	  } else if (authorKey.length == 2) {
		authorKeyFixed = authorKey[0] + " and " + authorKey[1];
	  } else if (authorKey.length == 3) {
		authorKeyFixed = authorKey[0] + ", " + authorKey[1] + " and " + authorKey[2];
	  } else if (authorKey.length > 3) {
		authorKeyFixed = authorKey[0] + " et al.";
	  }
	  if (authorKey.length > 0) {
		combinedCreators = authorKeyFixed;
	  }
  
	  if (editorKey.length == 1) {
		editorKeyFixed = editorKey[0];
	  } else if (editorKey.length == 2) {
		editorKeyFixed = editorKey[0] + " and " + editorKey[1];
	  } else if (editorKey.length == 3) {
		editorKeyFixed = editorKey[0] + ", " + editorKey[1] + " and " + editorKey[2];
	  } else if (editorKey.length > 3) {
		editorKeyFixed = editorKey[0] + " et al.";
	  }
	  if (editorKey.length > 0) {
		combinedCreators = editorKeyFixed;
	  }


	  // Identify the combined authors name for the reference Harvard (e.g. Surname, F., Surname et al.)
	  let combinedCreatorsHarvard = '';
	  const authorKeyHarvard = [];
	  const editorKeyHarvard = [];
	  let authorKeyFixedHarvard = "";
	  let editorKeyFixedHarvard = "";
  
	  for (let creator of item.creators) {
		if (creator.creatorType === "author") {
		  if (creator.name) {
			authorKeyHarvard.push(creator.name);
		} else if (creator.lastName && creator.firstName) {
			authorKeyHarvard.push(creator.lastName + " " + creator.firstName.charAt(0) +"."  );
		  } else if (creator.lastName) {
			authorKeyHarvard.push(creator.lastName);
		  } else if (creator.firstName) {
			authorKeyHarvard.push(creator.firstName);
		  }
		} else if (creator.creatorType === "editor") {
		  if (creator.name) {
			editorKeyHarvard.push(creator.name);
		  } 
		  else if (creator.lastName && creator.firstName) {
			editorKeyHarvard.push(creator.lastName + " " + creator.firstName.charAt(0) +"."  );}
		  else if (creator.lastName) {
			editorKeyHarvard.push(creator.lastName);
		  } else if (creator.firstName) {
			editorKeyHarvard.push(creator.firstName);
		  }
		}
	  }
  
	  // Adjust the authorKey depending on the number of authors
	  if (authorKeyHarvard.length == 1) {
		authorKeyFixedHarvard = authorKeyHarvard[0];
	  } else if (authorKey.length == 2) {
		authorKeyFixedHarvard = authorKeyHarvard[0] + " and " + authorKeyHarvard[1];
	  } else if (authorKey.length == 3) {
		authorKeyFixedHarvard = authorKeyHarvard[0] + ", " + authorKeyHarvard[1] + " and " + authorKeyHarvard[2];
	  } else if (authorKeyHarvard.length > 3) {
		authorKeyFixedHarvard = authorKeyHarvard[0] + " et al.";
	  }
	  if (authorKey.length > 0) {
		combinedCreatorsHarvard = authorKeyFixedHarvard;
	  }
  
	  if (editorKeyHarvard.length == 1) {
		editorKeyFixedHarvard = editorKeyHarvard[0];
	  } else if (editorKeyHarvard.length == 2) {
		editorKeyFixedHarvard = editorKeyHarvard[0] + " and " + editorKeyHarvard[1];
	  } else if (editorKeyHarvard.length == 3) {
		editorKeyFixedHarvard = editorKeyHarvard[0] + ", " + editorKeyHarvard[1] + " and " + editorKeyHarvard[2];
	  } else if (editorKeyHarvard.length > 3) {
		editorKeyFixedHarvard = editorKeyHarvard[0] + " et al.";
	  }
	  if (editorKeyHarvard.length > 0) {
		combinedCreatorsHarvard = editorKeyFixedHarvard;
	  }
  
	  // Date for the title
	  var date = Zotero.Utilities.strToDate(item.date);
	  var dateS = (date.year) ? date.year : item.date;
  
      //Set the title
      var fullTitle = combinedCreators + '. ' + "'__" + item.title + "__'"  + " #source";

      if (item.itemType === 'journalArticle') {
        fullTitle = combinedCreators + '. ' + "'__" + item.title + "__'" + " #article"
        }

		 if (item.itemType === 'book') {
        fullTitle = combinedCreators + '. ' + "'__" + item.title + "__'" +  " #book"
        }	
	  Zotero.write('- ' + fullTitle + '\n');
  
	  // Citekey
	  Zotero.write('  - citekey:: ' + item.citationKey + '\n');
  
	  // Set the author list
	  if (item.creators !== undefined) {
		Zotero.write('  - Author::\n');
		for (let creator of item.creators) {
		  if (creator.firstName && creator.lastName) {
			// Use the full name of the author. Should be the most common situation
			Zotero.write('    - [[' + creator.lastName + ', ' + creator.firstName + ' #author]]\n');
		  } else if (creator.lastName) {
			// Only use the last name
			Zotero.write('    - [[' + creator.lastName + ' #author]]\n');
		  } else {
			// Hypothetically impossible unless your DB is inconsistent for some reason
			Zotero.write('    - Unknown author\n');
		  }
		}
	  }
  
	  // Year
	  Zotero.write('  - Year:: ' + (dateS || '') + '\n');
  
	  // Publication
	  Zotero.write('  - Journal:: ' + (item.publicationTitle || '') + ' #[[journal]]\n');
  
	  // Zotero link
	  var library_id = item.libraryID ? item.libraryID : 0;
	  var itemLink = 'zotero://select/items/' + library_id + '_' + item.key;
	  Zotero.write('  - Zotero link:: [Zotero Link](' + itemLink + ')\n');
  
	  // URL with citation
	  Zotero.write('  - URL:: ' + (item.url || '') + '\n');
  
  
	  // Abstract. Change the \n to a multiline string
	  Zotero.write('  - Abstract:: ' + (item.abstractNote || '').replace(/\n/g, ' ') + '\n');
  
	  // Create the full reference for academic sources
	  var fullReference = combinedCreatorsHarvard;
	  if (dateS) {
		fullReference += ' (' + dateS + ') ';
	  }
	  if (item.itemType === 'journalArticle') {
			  fullReference += "'" + item.title + "'"+', ';
		fullReference += "__"+ item.publicationTitle  + "__"+ ",";
		if (item.volume, fullReference += ' '+ item.volume);
		if (item.issue && typeof item.issue != 'undefined', fullReference += '('+ item.issue +')');
		if (item.pages, fullReference += ', pp. '+ item.pages +'.');
	  if (item.DOI, fullReference += ' doi: '+ "["+item.DOI+"](" + item.url + ")") +'.';
  
	  }
  if (item.itemType === 'book') {
    fullReference += "__" + item.title + "__"+ ', ';
    if (item.place) {
        fullReference += ' ' + item.place;
    }
    if (item.place && item.publisher) {
        fullReference += ': ';
    }
    if (item.publisher) {
        fullReference += item.publisher + ".";
    }
	 if (item.edition) {
        fullReference += " " + item.edition + ".";
    }
    if ('DOI' in item) {
        fullReference += ' doi: ' + "[" + item.DOI + "](" + item.url + ")" + '.';
    }
}

	  if (fullReference) {
		Zotero.write('  - Citation:: ' + fullReference + '\n');
	  }
  
// Set the tags
	  if (item.tags !== undefined) {
		Zotero.write('  - Topic::\n');
		for (let tags of item.tags) {
			// Use the full name of the author. Should be the most common situation
			Zotero.write('    - [[' + tags.tag + ' #topic]]\n');
		}
	  }

	  //Extract the annotations
	  var fullAnnotations = ''
	if(item.notes[0] !== undefined) {
		Zotero.write('\n' + '\n');
		Zotero.write(`  - Highlights`);
		Zotero.write('\n');

		fullAnnotations = decodeURIComponent(item.notes[0].note)

		fullAnnotations = fullAnnotations
			// .replace(
			// 	Remove HTML tags
			// 	HTML_TAG_REG,
			// 	"")
			// 	Replace backticks
			.replace(/`/g, "'")
			// Correct when zotero exports wrong key (e.g. Author, date, p. p. pagenum)
			.replace(/, p. p. /g, ", p. ")
			.trim();
	
		const lines = fullAnnotations.split(/<\/h1>|<\/p>|<h1>/gm);
		const lengthLines = Object.keys(lines).length;


		for (let indexLines = 1; indexLines < lengthLines; indexLines++) {

			const selectedLineOriginal = unescape(lines[indexLines]);

			//Remove HTML tags
			let selectedLine = String(
				selectedLineOriginal.replace(/<\/?[^>]+(>|$)/g, "")
			);
			// 	// Replace backticks with single quote
			selectedLine = selectedLine.replace("`", "'");
			//selectedLine = replaceTemplate(selectedLine, "/<i/>", "");
			// 	// Correct encoding issues
			selectedLine = selectedLine.replace("&amp;", "&");

			//remove line break
			selectedLine = selectedLine.replace(/[\r\n]+/g, '');
			// skip if the line start with Annotation
			if(selectedLine.startsWith("Annotations")) {continue};
			//skip if the line is too short
			if(selectedLine.length<2) {continue};

			//print out the highlight
			Zotero.write('    - ' + selectedLine + ' #highlight');
			//print the properties of the highlight
			
			//Extracte the page of the pdf
			if (/"pageIndex":\d+/gm.test(selectedLineOriginal)) {
				let pagePDF = String(
					selectedLineOriginal.match(/"pageIndex":\d+/gm)
				);
				if (pagePDF == null) {
					highlightPagePDF = null;
				} else {
					pagePDF = pagePDF.replace('"pageIndex":', "");
					highlightPagePDF = Number(pagePDF) + 1;
				}
			}

			//Extracte the page of the annotation in the publication
			if (/"pageLabel":"\d+/g.test(selectedLineOriginal)) {
				let pageLabel = String(
					selectedLineOriginal.match(/"pageLabel":"\d+/g)
				);
				if (pageLabel == null) {
					highlightPageLabel = null;
				} else {
					pageLabel = pageLabel.replace('"pageLabel":"', "");
					highlightPageLabel = Number(pageLabel);
				}
				
			}

			//Extract the attachment URI
			if (
				/attachmentURI":"http:\/\/zotero\.org\/users\/\d+\/items\/\w+/gm.test(
					selectedLineOriginal
				)
			) {
				let attachmentURI = String(
					selectedLineOriginal.match(
						/attachmentURI":"http:\/\/zotero\.org\/users\/\d+\/items\/\w+/gm
					)
				);
				if (attachmentURI === null) {
					highlightAttachmentURI = null;
				} else {
					attachmentURI = attachmentURI.replace(
						/attachmentURI":"http:\/\/zotero\.org\/users\/\d+\/items\//gm,
						""
					);
					highlightAttachmentURI = attachmentURI;
				}
			}


			if (
				/"attachmentURI":"http:\/\/zotero.org\/users\/local\/[a-zA-Z0-9]*\/items\/[a-zA-Z0-9]*/gm.test(
					selectedLineOriginal
				)
			) {
				let attachmentURI = String(
					selectedLineOriginal.match(
						/"attachmentURI":"http:\/\/zotero.org\/users\/local\/[a-zA-Z0-9]*\/items\/[a-zA-Z0-9]*/gm
					)
				);
				if (attachmentURI === null) {
					highlightAttachmentURI = null;
				} else {
					attachmentURI = attachmentURI.replace(
						/"attachmentURI":"http:\/\/zotero.org\/users\/local\/[a-zA-Z0-9]*\/items\//gm,
						""
					);
					highlightAttachmentURI = attachmentURI;
				}
			}

			if (
				/"uris":\["http:\/\/zotero\.org\/users\/\d+\/items\/\w+/gm.test(
					selectedLineOriginal
				) && highlightAttachmentURI == ""
			) {
				let attachmentURI = String(
					selectedLineOriginal.match(
						/"uris":\["http:\/\/zotero\.org\/users\/\d+\/items\/\w+/g
					)
				);
				if (attachmentURI === null) {
					highlightAttachmentURI = null;
				} else {
					attachmentURI = attachmentURI.replace(
						/"uris":\["http:\/\/zotero\.org\/users\/\d+\/items\//g,
						""
					);
					highlightAttachmentURI = attachmentURI;
				}

			}


			//Create the zotero backlink			
			if (/"annotationKey":"[a-zA-Z0-9]+/gm.test(selectedLineOriginal)) {
				let annotationKey = String(selectedLineOriginal.match(/"annotationKey":"[a-zA-Z0-9]+/gm));
				if (annotationKey === null) {
					highlightAnnotationKey = null;
				} else {
					annotationKey = annotationKey.replace(/"annotationKey":"/gm, "");
					highlightAnnotationKey = annotationKey;
				}
			}
			if (highlightAttachmentURI !== null && highlightPagePDF !== null && highlightAnnotationKey !== null) {
				highlightZoteroBackLink = "zotero://open-pdf/library/items/" + highlightAttachmentURI + "?page=" + highlightPagePDF + "&annotation=" + highlightAnnotationKey;

			}

			//Extract the citation within bracket
			if (
				/\(<span class="citation-item">.*<\/span>\)<\/span>/gm.test(
					selectedLineOriginal
				)
			) {
				highlightCiteKey = String(
					selectedLineOriginal.match(
						/\(<span class="citation-item">.*<\/span>\)<\/span>/gm
					)
				);
				highlightCiteKey = highlightCiteKey.replace(
					'(<span class="citation-item">',
					""
				);
				highlightCiteKey = highlightCiteKey.replace(
					"</span>)</span>",
					""
				);
				highlightCiteKey = "(" + highlightCiteKey + ")";
			}

			//Find the position where the CiteKey begins
			const beginningCiteKey = selectedLine.indexOf(highlightCiteKey);

			//Find the position where the citekey ends
			const endCiteKey =
				selectedLine.indexOf(highlightCiteKey) +
				highlightCiteKey.length;

			//Extract the text of the annotation
			if (endCiteKey !== 0) {
				highlightText = selectedLine.substring(0, beginningCiteKey - 1).trim();
				highlightText = highlightText.replace(/((?<=\p{Unified_Ideograph})\s*(?=\p{Unified_Ideograph}))/ug, '');
				highlightText = highlightText.replace(highlightCiteKey, '');
				let cleanedHighlightCiteKey = highlightCiteKey.replace(/, p\. \d+\)$/, ')');
				highlightText = highlightText.replace(cleanedHighlightCiteKey, '');



				// Remove quotation marks from annotationHighlight
				function removeQuoteFromStart(quote, annotation) {
    				let copy = annotation.slice();
    				while (copy.charAt(0) === quote) {
        			copy = copy.substring(1);
    				}
    				return copy;
					}
				["“", '"', "`", "'"].forEach(
					(quote) =>
					(highlightText = removeQuoteFromStart(
						quote,
						highlightText
					))
				);

				function removeQuoteFromEnd(quote, annotation) {
					let copy = annotation.slice();
					while (copy[copy.length - 1] === quote)
					copy = copy.substring(0, copy.length - 1);
					return copy;
					}
				["”", '"', "`", "'"].forEach(
					(quote) =>
					(highlightText = removeQuoteFromEnd(
						quote,
						highlightText
					))
				);
			}

			//Extract the colour
			// Regular expression to extract the color value
			let colorRegex = /"color":"#([a-fA-F0-9]{6})"/;

			// Use match to find the color value
			let match = selectedLineOriginal.match(colorRegex);

			// Extract the color value from the match
			let highlightColor = match ? `#${match[1]}` : null;

			//Extract the comments and tags
			if (endCiteKey !== 0) {
				afterHighlightText = selectedLine.substring(endCiteKey, selectedLine.length).trim();}
			if (endCiteKey !== 0) {
				afterHighlightText = selectedLine.substring(endCiteKey, selectedLine.length).trim();}

			// Find the position of the first # character
				let hashPosition = afterHighlightText.indexOf('#');
			// extract the comment before the hash
			let highlightComment;
		if (hashPosition !== -1) {
    		highlightComment = afterHighlightText.substring(0, hashPosition);
			} else {
		    highlightComment = afterHighlightText;
			}

			// Extract the text from the first # character to the end of the string
				let extractedTagsString= afterHighlightText.substring(hashPosition);
				if (extractedTagsString.startsWith('#')) {    extractedTagsString = extractedTagsString.substring(1);}
				let extractedTagsArray = extractedTagsString.split(' #').filter(tag => tag.trim() !== "");
				
				



			//Print highlight fields
			if(highlightPagePDF>0) {Zotero.write('\n' + '      - Page Number:: ' + highlightPagePDF);}
			//if(highlightPageLabel>0) {Zotero.write('\n' + '      - Page Label:: ' + highlightPagePDF);}
			//if(highlightAttachmentURI) {Zotero.write('\n' + '      - highlightAttachmentURI:: ' + highlightAttachmentURI);}
			if(highlightZoteroBackLink) {Zotero.write('\n' + '      - highlightZoteroBackLink:: ' + highlightZoteroBackLink);}
			if(highlightCiteKey) {Zotero.write('\n' + '      - highlightCiteKey:: ' + highlightCiteKey);}
			if(highlightText) {Zotero.write('\n' + '      - highlightText:: ' + highlightText);}
			if(highlightColor) {Zotero.write('\n' + '      - highlightColor:: ' + highlightColor);}
			if(highlightComment) {Zotero.write('\n' + '      - highlightComment:: ' + highlightComment);}
			if(extractedTagsString) {Zotero.write('\n' + '      - extractedTagsString:: ' + extractedTagsString);}
			if(extractedTagsString) {Zotero.write('\n' + '      - extractedTagsArray:: ' + extractedTagsArray);}
			if (extractedTagsArray.length > 0 && extractedTagsArray !== undefined) {
    			Zotero.write('      - Topic::\n');
   			 for (let tag of extractedTagsArray) {
        Zotero.write('        - [[' + tag + ' #topic]]\n');
    }
}




	   	  Zotero.write('\n');

		}



	  // Zotero.write('\n' + JSON.stringify(item, null, 2) + '\n');
		// Zotero.write('\n' + '\n' + "ANNOTATIONS");
	   	 //  Zotero.write('\n' + fullAnnotations + '\n');

	}

			Zotero.write('\n');
			//Zotero.write(combinedCreatorsHarvard);
			//Zotero.write('\n' + JSON.stringify(decodeURIComponent(item.notes[0].note), null, 2) + '\n');

	}
  }	  