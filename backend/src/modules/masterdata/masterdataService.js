const LOCATIONS = {
  provinces: [
    { id: '31', name: 'DKI Jakarta' },
    { id: '32', name: 'Jawa Barat' },
    { id: '33', name: 'Jawa Tengah' },
    { id: '35', name: 'Jawa Timur' },
  ],
  regencies: {
    31: [
      { id: '3171', province_id: '31', name: 'Kota Jakarta Selatan' },
      { id: '3172', province_id: '31', name: 'Kota Jakarta Timur' },
      { id: '3173', province_id: '31', name: 'Kota Jakarta Pusat' },
      { id: '3174', province_id: '31', name: 'Kota Jakarta Barat' },
    ],
    32: [
      { id: '3201', province_id: '32', name: 'Kabupaten Bogor' },
      { id: '3204', province_id: '32', name: 'Kabupaten Bandung' },
      { id: '3273', province_id: '32', name: 'Kota Bandung' },
      { id: '3271', province_id: '32', name: 'Kota Bogor' },
    ],
    33: [
      { id: '3301', province_id: '33', name: 'Kabupaten Cilacap' },
      { id: '3319', province_id: '33', name: 'Kabupaten Jepara' },
      { id: '3374', province_id: '33', name: 'Kota Semarang' },
      { id: '3372', province_id: '33', name: 'Kota Surakarta' },
    ],
    35: [
      { id: '3501', province_id: '35', name: 'Kabupaten Pacitan' },
      { id: '3515', province_id: '35', name: 'Kabupaten Sidoarjo' },
      { id: '3578', province_id: '35', name: 'Kota Surabaya' },
      { id: '3573', province_id: '35', name: 'Kota Malang' },
    ],
  },
};

export function getProvinces() {
  return LOCATIONS.provinces;
}

export function getRegencies(provinceId) {
  const regencies = LOCATIONS.regencies[provinceId];
  if (!regencies) {
    throw { status: 404, message: 'Provinsi tidak ditemukan' };
  }
  return regencies;
}

export function getPredefinedSkills() {
  return [
    'Tukang Kayu',
    'Tukang Masak',
    'Penjahit',
    'Tukang Ojol',
    'Tukang Bangunan',
    'Supir Angkut Barang',
    'Tukang Las',
    'ART',
    'Tukang Ojek Barang',
    'Lainnya',
  ];
}