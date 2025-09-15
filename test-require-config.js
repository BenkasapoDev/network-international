try {
    const config = require('./prisma.config.cjs');
    console.log('CONFIG_OK', config);
} catch (e) {
    console.error('CONFIG_ERROR', e && e.stack ? e.stack : e);
    process.exit(1);
}
