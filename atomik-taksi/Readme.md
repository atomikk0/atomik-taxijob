# atomik-taksi

YMAP VE TAKSİ METRE BENİM DEĞİLDİR

qbcore>shared>jobs.lua
```lua
	['taxi'] = {
		label = 'Taksi',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
            ['0'] = {
                name = 'Stajyer',
                payment = 50
            },
			['1'] = {
                name = 'Sürücü',
                payment = 75
            },
			['2'] = {
                name = 'Menajer',
				isboss = true,
                payment = 100
            },
        
```

qb-management>client>cl_config.lua

```lua
Config.BossMenus = {
    ['taxi'] = {
        vector3(906.9694, -150.402, 74.952),
    },
}
Config.BossMenuZones = {
    ['taxi'] = {
        { coords =  vector3(906.9694, -150.402, 74.952), length = 1.15, width = 2.6, heading = 353.0, minZ = 70.59, maxZ = 76.99 },
    },
}
```

Görsel:

![image]( https://cdn.discordapp.com/attachments/1119221551657648168/1131099281391095838/image.png ) 


Gerekli Script:

- [qb-menu](https://github.com/qbcore-framework/qb-menu)
