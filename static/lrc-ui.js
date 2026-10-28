'use strict';

const lrcImportInput = document.getElementById('lrcImportInput');
lrcImportInput?.addEventListener('change', async () => {
  const file = lrcImportInput.files?.[0];
  if (!file) return;
  try {
    const source = await file.text();
    const lines = source.split(/\r?\n/)
      .filter(line => !/^\s*\[[a-z]{2,}:/i.test(line))
      .map(line => line.replace(/^\s*(?:\[\d{1,3}:\d{2}(?:[.:]\d{1,3})?\]\s*)+/, '').trim())
      .filter(Boolean);
    if (!lines.length) throw new Error('No se encontró texto de letra en el archivo.');
    document.getElementById('lyricsInput').value = lines.join('\n');
    document.getElementById('lyricsInput').dispatchEvent(new Event('input', { bubbles: true }));
    toast(`Letra importada desde ${file.name}. Whisper recalculará los tiempos; las marcas LRC originales no se conservan.`, 'success');
  } catch (error) {
    toast(`No se pudo importar el archivo: ${error.message}`, 'error');
  } finally {
    lrcImportInput.value = '';
  }
});
