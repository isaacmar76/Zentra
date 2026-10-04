// Serverless Function de Vercel para envío de copia de seguridad de Zentra
// Ruta: /api/send-backup

module.exports = async function handler(req, res) {
  // Configuración de cabeceras CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, error: 'Método no permitido. Solo se acepta POST.' });
  }

  try {
    const { email, bizName, bizOwner, backupDate, backupJson, summary } = req.body || {};

    if (!email || !email.includes('@')) {
      return res.status(400).json({ success: false, error: 'Correo electrónico de destinatario no válido.' });
    }

    if (!backupJson) {
      return res.status(400).json({ success: false, error: 'Contenido de copia de seguridad no provisto.' });
    }

    const cleanBizName = (bizName || 'Mi_Negocio').replace(/[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ_ -]/g, '');
    const filename = `Zentra_Respaldo_${cleanBizName.replace(/\s+/g, '_')}.json`;
    const base64Attachment = Buffer.from(backupJson).toString('base64');

    const sumHtml = summary ? `
      <ul style="color:#4B5563; font-size:14px; line-height:1.6;">
        <li><b>Proyectos / Encargos:</b> ${summary.totalProyectos || 0}</li>
        <li><b>Productos y Servicios en Catálogo:</b> ${summary.totalCatalogo || 0}</li>
        <li><b>Cotizaciones Guardadas:</b> ${summary.totalCotizaciones || 0}</li>
        <li><b>Tareas de Taller:</b> ${summary.totalTareas || 0}</li>
        <li><b>Directorio de Clientes:</b> ${summary.totalClientes || 0}</li>
      </ul>
    ` : '';

    const htmlContent = `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width:600px; margin:0 auto; background:#ffffff; border-radius:18px; padding:28px 24px; border:1px solid #E5EEFF;">
        <div style="text-align:center; margin-bottom:20px;">
          <h1 style="color:#006C46; font-size:24px; margin:0; font-weight:800;">ZENTRA</h1>
          <p style="color:#596273; font-size:13px; margin:4px 0 0;">Gestión Ágil para Micronegocios y Talleres</p>
        </div>
        
        <div style="background:#F0FDF4; border:1px solid #BBF7D0; border-radius:14px; padding:16px; margin-bottom:20px;">
          <h2 style="color:#166534; font-size:16px; margin:0 0 6px;">🛡️ Copia de Seguridad Exitosa</h2>
          <p style="color:#15803D; font-size:13px; margin:0;">
            Hola <b>${bizOwner || 'Dueño(a)'}</b>, se ha generado el respaldo completo de tu negocio <b>"${cleanBizName}"</b> el <b>${backupDate || 'hoy'}</b>.
          </p>
        </div>

        <h3 style="color:#0B1C30; font-size:14px; margin:16px 0 8px;">📊 Resumen de tu Negocio:</h3>
        ${sumHtml}

        <div style="background:#EFF4FF; border:1px solid #D5E3FF; border-radius:12px; padding:14px; margin-top:20px;">
          <p style="color:#1E3A8A; font-size:12.5px; margin:0; line-height:1.5;">
            <b>¿Cómo restaurar tu negocio?</b><br>
            Descarga el archivo adjunto <code>${filename}</code>. Si cambias de teléfono o borras tu navegador, entra a Zentra, ve a <i>Mi Negocio &gt; Restaurar Negocio</i> y selecciona este archivo. Todo volverá a estar exactamente como lo dejaste.
          </p>
        </div>

        <div style="text-align:center; margin-top:26px; font-size:11px; color:#9CA3AF; border-top:1px solid #F3F4F6; padding-top:14px;">
          Zentra • Sistema Operativo para los Negocios de Colombia
        </div>
      </div>
    `;

    // 1. Envío mediante Resend API si la llave está configurada
    if (process.env.RESEND_API_KEY) {
      const resendRes = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          from: process.env.RESEND_FROM || 'Zentra Backup <onboarding@resend.dev>',
          to: [email],
          subject: `🛡️ Copia de Seguridad Zentra - ${cleanBizName} (${backupDate})`,
          html: htmlContent,
          attachments: [
            {
              filename: filename,
              content: base64Attachment
            }
          ]
        })
      });

      const resendData = await resendRes.json();
      if (resendRes.ok) {
        return res.status(200).json({ success: true, message: 'Correo enviado vía Resend', id: resendData.id });
      } else {
        console.error('Error de Resend:', resendData);
      }
    }

    // 2. Si no hay llaves aún configuradas en las variables de entorno de Vercel
    return res.status(200).json({
      success: false,
      reason: 'no_api_key',
      message: 'Para envío automático directo desde Vercel, configura la variable RESEND_API_KEY en los Settings de Vercel. Se usará el cliente de correo alternativo de inmediato.'
    });

  } catch (error) {
    console.error('Error procesando backup serverless:', error);
    return res.status(500).json({ success: false, error: error.message || 'Error interno del servidor' });
  }
};
