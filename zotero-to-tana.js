{
  "translatorID": "dda092d2-a257-46af-b9a3-2f04a55cb04f",
  "translatorType": 2,
  "label": "Tana Zotero Export",
  "creator": "Stian Håklev, Joel Chan, Maggie Appleton, Jen Murtazashvili)",
  "target": "md",
  "minVersion": "2.0",
  "priority": 200,
  "inRepository": false,
  "lastUpdated": "2025-05-24"
}

function stripAndSplit(html) {
  html = html
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<\/(div|p|li|blockquote)>/gi, '\n')
    .replace(/<li[^>]*>/gi, '\n')
    .replace(/<div[^>]*>/gi, '\n')
    .replace(/<p[^>]*>/gi, '\n');
  const plain = html.replace(/<[^>]*>/g, '');
  return plain.split(/\n+/).map(t => t.trim()).filter(Boolean);
}

function extractDOI(item) {
  if (item.DOI) return item.DOI;
  if (item.extra) {
    const m = item.extra.match(/DOI\s*:\s*(\S+)/i);
    if (m) return m[1];
  }
  return null;
}

function findFirstPDF(item) {
  if (!item.attachments) return null;
  for (const a of item.attachments) {
    if (a.mimeType === 'application/pdf') return a.itemID;
  }
  return null;
}

function doExport() {
  Zotero.write('%%tana%%\n');
  let item;
  while ((item = Zotero.nextItem())) {
    const typeMap = {
      journalArticle:  'article',
      magazineArticle: 'magazine article',
      newspaperArticle:'newspaper article',
      blogPost:        'blog',
      bookSection:     'book section',
      book:            'book',
      conferencePaper: 'conference paper',
      thesis:          'thesis',
      report:          'report',
      document:        'document',
      preprint:        'working paper'
    };
    const typeTag = typeMap[item.itemType] || item.itemType;

    Zotero.write(`- ${item.title} #${typeTag} #zotero\n\n`);

    Zotero.write('  - Author::\n');
    item.creators.forEach(c => {
      Zotero.write(`    - [[${c.firstName || ''} ${c.lastName || ''}]]\n`);
    });

    Zotero.write('\n  - Topic:: \n');

    const y = Zotero.Utilities.strToDate(item.date);
    const year = (y && y.year) || item.date || '';
    Zotero.write(`  - Year:: ${year}\n`);
    if (item.publisher)       Zotero.write(`  - Publisher:: ${item.publisher}\n`);
    if (item.publicationTitle) Zotero.write(`  - Publication:: ${item.publicationTitle}\n`);

    if (item.url) Zotero.write(`  - Link:: [${item.url}](${item.url})\n`);
    const doi = extractDOI(item);
    if (doi) Zotero.write(`  - DOI:: [${doi}](https://doi.org/${doi})\n`);
    const pdf = findFirstPDF(item);
    if (pdf) Zotero.write(`  - PDF:: [open](zotero://open-pdf/items/${pdf})\n`);

    if (item.abstractNote) Zotero.write(`  - Abstract:: ${item.abstractNote}\n`);

    if (item.notes && item.notes.length) {
      Zotero.write('  - Notes::\n');
      item.notes.forEach(n => {
        stripAndSplit(n.note).forEach(line => {
          Zotero.write(`    - ${line}\n`);
        });
      });
    }

    Zotero.write('\n');
  }
}
