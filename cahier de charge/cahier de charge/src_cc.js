const fs = require('fs');

function downloadAll() {
    // Créer le contenu du cahier des charges complet
    const content = generateCompleteCahier();
    
    // Créer un blob avec le contenu
    const blob = new Blob([content], { type: 'text/markdown' });
    
    // Créer un lien de téléchargement
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = 'Cahier_Charges_MERISE_HR_Nexus.md';
    
    // Simuler le clic
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // Afficher une notification
    alert('Téléchargement du cahier des charges démarré !');
}

function downloadPDF() {
    alert('Fonctionnalité PDF en cours de développement. Téléchargez la version Markdown pour l\'instant.');
}

function downloadDOC() {
    alert('Fonctionnalité Word en cours de développement. Téléchargez la version Markdown pour l\'instant.');
}

function downloadMD() {
    const content = generateCompleteCahier();
    const blob = new Blob([content], { type: 'text/markdown' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = 'Cahier_Charges_MERISE_HR_Nexus.md';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    alert('Cahier des charges Markdown téléchargé !');
}

function generateCompleteCahier() {
    return fs.readFile('./cahier_de_charge.md', 'utf8', (err, data) => {
        if (err) {
            throw new Error(`erreur import chahier de charge en fichier src_cc.js: ${err}`);
        }
        return data;
    })
}