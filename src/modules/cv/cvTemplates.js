export function renderCvTemplate(templateId, data) {
  const {
    fullName, position, summary,
    experience = [], education = [], skills = [],
  } = data;

  const experienceHtml = experience.map(exp => `
    <div class="item">
      <h3>${exp.position || ''} — ${exp.company || ''}</h3>
      <p class="period">${exp.startDate || ''} - ${exp.endDate || 'Sekarang'}</p>
      <p>${exp.description || ''}</p>
    </div>
  `).join('');

  const educationHtml = education.map(edu => `
    <div class="item">
      <h3>${edu.institution || ''}</h3>
      <p class="period">${edu.startYear || ''} - ${edu.endYear || ''}</p>
      <p>${edu.degree || ''}</p>
    </div>
  `).join('');

  const skillsHtml = skills.map(skill => `<span class="skill">${skill}</span>`).join('');

  return `
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <style>
      body { font-family: Arial, sans-serif; padding: 40px; color: #222; }
      h1 { margin-bottom: 4px; }
      .position { color: #555; margin-bottom: 20px; }
      h2 { border-bottom: 2px solid #333; padding-bottom: 4px; margin-top: 24px; }
      .item { margin-bottom: 12px; }
      .item h3 { margin-bottom: 2px; }
      .period { color: #777; font-size: 12px; margin: 0 0 4px; }
      .skill { display: inline-block; background: #eee; padding: 4px 10px; margin: 4px 4px 0 0; border-radius: 4px; font-size: 12px; }
    </style>
  </head>
  <body>
    <h1>${fullName || ''}</h1>
    <p class="position">${position || ''}</p>

    <h2>Ringkasan</h2>
    <p>${summary || '-'}</p>

    <h2>Pengalaman Kerja</h2>
    ${experienceHtml || '<p>-</p>'}

    <h2>Pendidikan</h2>
    ${educationHtml || '<p>-</p>'}

    <h2>Keahlian</h2>
    <div>${skillsHtml || '-'}</div>
  </body>
  </html>
  `;
}