function renderContactLine(contact) {
  const parts = [contact.phone, contact.email, contact.location].filter(Boolean);
  return parts.join(' &nbsp;|&nbsp; ');
}

function renderTemplate1(data) {
  const {
    fullName, position, summary, contact = {},
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
      <p>${edu.description || ''}</p>
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
      .position { color: #555; margin-bottom: 4px; }
      .contact { color: #777; font-size: 12px; margin-bottom: 20px; }
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
    <p class="contact">${renderContactLine(contact)}</p>

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

function renderTemplate2(data) {
  const {
    fullName, position, summary, contact = {},
    experience = [], education = [], skills = [],
  } = data;

  const experienceHtml = experience.map(exp => `
    <div class="timeline-item">
      <div class="dot"></div>
      <div class="timeline-content">
        <h3>${exp.position || ''}</h3>
        <p class="company">${exp.company || ''}</p>
        <p class="period">${exp.startDate || ''} - ${exp.endDate || 'Sekarang'}</p>
        <p>${exp.description || ''}</p>
      </div>
    </div>
  `).join('');

  const educationHtml = education.map(edu => `
    <div class="timeline-item">
      <div class="dot"></div>
      <div class="timeline-content">
        <h3>${edu.institution || ''}</h3>
        <p class="period">${edu.startYear || ''} - ${edu.endYear || ''}</p>
        <p>${edu.description || ''}</p>
      </div>
    </div>
  `).join('');

  const skillsHtml = skills.map(skill => `<span class="skill-pill">${skill}</span>`).join('');

  return `
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <style>
      body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; color: #2d2d2d; }
      .header { background: #1e5f74; color: #fff; padding: 40px; }
      .header h1 { margin: 0 0 4px; font-size: 28px; }
      .header .position { font-size: 14px; opacity: 0.9; letter-spacing: 1px; text-transform: uppercase; }
      .header .contact { font-size: 12px; opacity: 0.85; margin-top: 8px; }
      .body-content { padding: 30px 40px; }
      h2 { color: #1e5f74; font-size: 15px; text-transform: uppercase; letter-spacing: 1px; margin-top: 28px; margin-bottom: 14px; }
      .timeline-item { position: relative; padding-left: 20px; margin-bottom: 16px; border-left: 2px solid #d8e8ec; }
      .dot { position: absolute; left: -6px; top: 4px; width: 10px; height: 10px; border-radius: 50%; background: #1e5f74; }
      .timeline-content h3 { margin: 0 0 2px; font-size: 15px; }
      .company { margin: 0; font-size: 13px; color: #1e5f74; font-weight: 600; }
      .period { color: #888; font-size: 12px; margin: 2px 0 6px; }
      .skill-pill { display: inline-block; background: #1e5f74; color: #fff; padding: 5px 12px; margin: 4px 6px 0 0; border-radius: 20px; font-size: 12px; }
    </style>
  </head>
  <body>
    <div class="header">
      <h1>${fullName || ''}</h1>
      <p class="position">${position || ''}</p>
      <p class="contact">${renderContactLine(contact)}</p>
    </div>
    <div class="body-content">
      <h2>Ringkasan</h2>
      <p>${summary || '-'}</p>

      <h2>Pengalaman Kerja</h2>
      ${experienceHtml || '<p>-</p>'}

      <h2>Pendidikan</h2>
      ${educationHtml || '<p>-</p>'}

      <h2>Keahlian</h2>
      <div>${skillsHtml || '-'}</div>
    </div>
  </body>
  </html>
  `;
}

function renderTemplate3(data) {
  const {
    fullName, position, summary, contact = {},
    experience = [], education = [], skills = [],
  } = data;

  const experienceHtml = experience.map(exp => `
    <div class="item">
      <h3>${exp.position || ''}</h3>
      <p class="company-period">${exp.company || ''} &nbsp;•&nbsp; ${exp.startDate || ''} - ${exp.endDate || 'Sekarang'}</p>
      <p>${exp.description || ''}</p>
    </div>
  `).join('');

  const educationHtml = education.map(edu => `
    <div class="item">
      <h3>${edu.institution || ''}</h3>
      <p class="company-period">${edu.startYear || ''} - ${edu.endYear || ''}</p>
      <p>${edu.description || ''}</p>
    </div>
  `).join('');

  const skillsHtml = skills.join(' &nbsp;·&nbsp; ');

  return `
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <style>
      body { font-family: Georgia, 'Times New Roman', serif; padding: 50px 60px; color: #333; }
      .center { text-align: center; }
      h1 { margin: 0 0 6px; font-size: 30px; letter-spacing: 1px; }
      .position { color: #666; font-style: italic; margin-bottom: 4px; }
      .contact { color: #888; font-size: 12px; margin-bottom: 20px; }
      .divider { border: none; border-top: 1px solid #ccc; width: 80px; margin: 20px auto; }
      h2 { text-align: center; font-size: 13px; text-transform: uppercase; letter-spacing: 3px; color: #999; margin-top: 30px; margin-bottom: 16px; }
      .item { margin-bottom: 16px; text-align: center; }
      .item h3 { margin: 0 0 2px; font-size: 16px; }
      .company-period { color: #777; font-size: 12px; font-style: italic; margin: 0 0 6px; }
      .skills-line { text-align: center; font-size: 13px; color: #555; }
    </style>
  </head>
  <body>
    <div class="center">
      <h1>${fullName || ''}</h1>
      <p class="position">${position || ''}</p>
      <p class="contact">${renderContactLine(contact)}</p>
      <hr class="divider" />
      <p>${summary || '-'}</p>
    </div>

    <h2>Pengalaman Kerja</h2>
    ${experienceHtml || '<p class="center">-</p>'}

    <h2>Pendidikan</h2>
    ${educationHtml || '<p class="center">-</p>'}

    <h2>Keahlian</h2>
    <p class="skills-line">${skillsHtml || '-'}</p>
  </body>
  </html>
  `;
}

const TEMPLATES = {
  template1: { name: 'Klasik', render: renderTemplate1 },
  template2: { name: 'Modern', render: renderTemplate2 },
  template3: { name: 'Minimalis', render: renderTemplate3 },
};

export function renderCvTemplate(templateId, data) {
  const template = TEMPLATES[templateId] || TEMPLATES.template1;
  return template.render(data);
}

export function getAvailableTemplates() {
  return Object.entries(TEMPLATES).map(([id, t]) => ({ id, name: t.name }));
}