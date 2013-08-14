core = {}

core.attributes =
  physical: ['bod', 'agi', 'rea', 'str']
  mental: ['wil', 'log', 'int', 'cha']
  special: ['ess', 'edg', 'mag', 'res']

# the basic physical and mental attributes
core.attributes.physicalMental = core.attributes.physical.concat core.attributes.mental
# attributes that every character/being has
core.attributes.universal = core.attributes.physicalMental.concat 'ess', 'edg'

limitsForMax = (obj)->
  for attr, val of obj
    obj[attr] =
      min: Math.max(1,val-5)
      max: val
  obj['ess'] =
    max: 6
  return obj

core.metatypes = ['human', 'elf', 'dwarf', 'ork', 'troll']
core.metatype =
  human:
    attributes: limitsForMax bod:6, agi:6, rea:6, str:6, wil:6, log:6, int:6, cha:6, edg:7
    racial: []
  elf:
    attributes: limitsForMax bod:6, agi:7, rea:6, str:6, wil:6, log:6, int:6, cha:8, edg:6
    racial: ['Low-Light Vision']
  dwarf:
    attributes: limitsForMax bod:8, agi:6, rea:5, str:8, wil:7, log:6, int:6, cha:6, edg:6
    racial: ['+2 dice for pathogen and toxin resistance', '+20% increased Lifestyle cost']
  ork:
    attributes: limitsForMax bod:9, agi:6, rea:6, str:8, wil:6, log:5, int:6, cha:5, edg:6
    racial: ['Low-Light Vision']
  troll:
    attributes: limitsForMax bod:10, agi:5, rea:6, str:10, wil:6, log:5, int:5, cha:4, edg:6
    racial: ['Thermographic Vision', '+1 Reach', '+1 dermal armor', '+100% increased Lifestyle costs']

# a few pre-made lists for skills
spellTypes = ['Combat Spells', 'Detection Spells', 'Health Spells', 'Illusion Spells', 'Manipulation Spells']
focusTypes = ['Enchanting Focus', 'Metamagic Focus', 'Power Focus', 'Qi Focus', 'Spell Focus', 'Spirit Focus', 'Weapon Focus']
spiritTypes = ['Spirits of Air', 'Spirits of Earth', 'Spirits of Beasts', 'Spirits of Fire', 'Spirits of Men', 'Spirits of Water']
spriteTypes = ['Courier Sprite', 'Crack Sprite', 'Data Sprite', 'Fault Sprite', 'Machine Sprite']

core.skill =
  groups: []
  categories: []
  skills: []

skill = (name, linkedAttribute, canDefault=false, specializations=[], specificExamples=null) ->
  result =
    name: name
    linkedAttribute: linkedAttribute
    canDefault : canDefault
    specializations: specializations
    specific: specificExamples != null
  if specificExamples
    result.specificExamples = specificExamples
  core.skill.skills.push result


skillCategory = (name, type, skills) ->
  result =
    name: name
    type: type
    skills: skills
  for s in skills
    s.category = name
  core.skill.categories.push result

skillGroup = (name, skills) ->
  result =
    name: name
    skills: [findSkill(s) for s in skills]
  core.skill.groups.push result

findSkill = (skillName) ->
  for skill in core.skill.skills
    if skill.name == skillName
      return skill
  throw new Error "No skill called #{skillName} found!"

skillCategory 'Combat Active', 'active', [
  skill 'Archery', 'agi', yes, ['Bow', 'Crossbow', 'Non-Standard Ammunition', 'Slingshot']
  skill 'Automatics', 'agi', yes, ['Assault Rifles', 'Cyber-Implant', 'Machine Pistols', 'Submachine Guns']
  skill 'Blades', 'agi', yes, ['Axes', 'Knives', 'Swords', 'Parrying']
  skill 'Clubs', 'agi', yes, ['Batons', 'Hammers', 'Saps', 'Staves', 'Parrying']
  skill 'Exotic Ranged Weapon', 'agi', false, [], ['Blowgun', 'Gyrojet Pistols', 'Flamethrowers', 'Lasers', null]
  skill 'Heavy Weapons', 'agi', yes, ['Assault Cannons', 'Grenade Launchers', 'Guided Missiles', 'Machine Guns', 'Rocket Launchers']
  skill 'Longarms', 'agi', yes, ['Extended-Range Shots', 'Long-Range Shots', 'Shotguns', 'Sniper Rifles']
  skill 'Pistols', 'agi', yes, ['Holdouts', 'Revolvers', 'Semi-Automatics', 'Tasers']
  skill 'Throwing Weapons', 'agi', yes, ['Aerodynamic','Blades','Non-Aerodynamic']
  skill 'Unarmed Combat', 'agi', yes, ['Blocking', 'Cyber-Implants', 'Subduing Combat', null]
]
skillCategory 'Physical Active', 'active', [
  skill 'Disguise', 'int', yes, ['Camouflage', 'Cosmetic', 'Theatrical', 'Trideo & Video']
  skill 'Diving', 'bod', yes, ['Liquid Breathing Aparatus', 'Mixed Gas', 'Oxygen Extraction', 'SCUBA', 'Arctic', 'Cave', 'Commercial', 'Military', null, 'Controlled Hyperventilation']
  skill 'Escape Artist', 'agi', yes, ['Cuffs', 'Ropes', 'Zip Ties', null, 'Contortionism']
  skill 'Free-Fall', 'bod', yes, ['BASE Jumping', 'Break-Fall', 'Bungee', 'HALO', 'Low Altitude', 'Parachute', 'Static Line', 'Wingsuit', 'Zipline']
  skill 'Gymnastics', 'agi', yes, ['Balance', 'Climbing', 'Dance', 'Leaping', 'Parkour', 'Rolling']
  skill 'Palming', 'agi', no, ['Legerdemain', 'Pickpocket', 'Pilfering']
  skill 'Perception', 'int', yes, ['Hearing', 'Scent', 'Searching', 'Taste', 'Touch', 'Visual']
  skill 'Running', 'str', yes, ['Distance', 'Sprinting', 'Desert', 'Urban', 'Wilderness', null]
  skill 'Sneaking', 'agi', yes, ['Jungle', 'Urban', 'Desert', null]
  skill 'Survival', 'wil', yes, ['Desert', 'Forest', 'Jungle', 'Mountain', 'Polar', 'Urban', null]
  skill 'Swimming', 'str', yes, ['Dash', 'Long Distance']
  skill 'Tracking', 'int', yes, ['Desert', 'Forest', 'Jungle', 'Mountain', 'Polar', 'Urban', null]
]
skillCategory 'Social', 'active', [
  skill 'Con', 'cha', yes, ['Fast Talking', 'Seduction']
  skill 'Etiquette', 'cha', yes, ['Corporate', 'High Society', 'Media', 'Mercenary', 'Street', 'Yakuza', null]
  skill 'Impersonation', 'cha', yes, ['Dwarf', 'Elf', 'Human', 'Ork', 'Troll']
  skill 'Instruction', 'cha', yes, ['Combat', 'Physical', 'Social', 'Magical', 'Resonance', 'Technical', 'Vehicle', 'Language', 'Academic Knowledge', 'Street Knowledge', 'Professional Knowledge', 'Interests']
  skill 'Intimidation', 'cha', yes, ['Interrogation', 'Mental', 'Physical', 'Torture']
  skill 'Leadership', 'cha', yes, ['Command', 'Direct', 'Inspire', 'Rally']
  skill 'Negotiation', 'cha', yes, ['Bargaining', 'Contracts', 'Diplomacy']
  skill 'Performance', 'cha', yes, ['Presentation', 'Acting', 'Comedy', null]
]
skillCategory 'Magical', 'active', [
  skill 'Alchemy', 'mag', no, ['Command', 'Contact', 'Time'].concat(spellTypes)
  skill 'Arcana', 'log', no, ['Spell Design', 'Focus Design', 'Spirit Formula']
  skill 'Artificing', 'mag', no, ['Focus Analysis'].concat(focusTypes)
  skill 'Assensing', 'int', no, ['Aura Reading', 'Astral Signatures', 'Metahuman', 'Spirits', 'Foci', 'Wards', null]
  skill 'Astral Combat', 'wil', no, ['Magicians', 'Spirits', 'Mana Barriers', null]
  skill 'Banishing', 'mag', no, spiritTypes
  skill 'Binding', 'mag', no, spiritTypes
  skill 'Counterspelling', 'mag', no, spellTypes
  skill 'Disenchanting', 'mag', no, ['Alchemical Preparations'].concat(focusTypes)
  skill 'Ritual Spellcasting', 'mag', no, ['Anchored', 'Material Link', 'Minion', 'Spell', 'Spotter']
  skill 'Spellcasting', 'mag', no, spellTypes
  skill 'Summoning', 'mag', no, spiritTypes
]
skillCategory 'Resonance', 'active', [
  skill 'Compiling', 'res', no, spriteTypes
  skill 'Decompiling', 'res', no, spriteTypes
  skill 'Registering', 'res', no, spriteTypes
]
skillCategory 'Technical', 'active', [
  skill 'Aeronautics Mechanic', 'log', no, ['Aerospace', 'Fixed Wing', 'LTA (blimp)', 'Rotary Wing', 'Tilt Wing', 'Vectored Thrust']
  skill 'Animal Handling', 'cha', yes, ['Herding', 'Riding', 'Training', 'Cat', 'Bird', 'Hell Hound', 'Horse', 'Dolphin', null]
  skill 'Armorer', 'log', yes, ['Armor', 'Artillery', 'Explosives', 'Firearms', 'Melee Weapons', 'Heavy Weapons', 'Weapon Accessories']
  skill 'Artisan', 'int', no, ['Cooking', 'Sculpting', 'Drawing', 'Carpentry', null]
  skill 'Automotive Mechanic', 'log', no, ['Walker', 'Hover', 'Tracked', 'Wheeled']
  skill 'Biotechnology', 'log', no, ['Bioinformatics', 'Bioware', 'Cloning','Gene Therapy', 'Vat Maintenance']
  skill 'Chemistry', 'log', no, ['Analytical', 'Biochemistry', 'Inorganic', 'Organic', 'Physical']
  skill 'Computer', 'log', yes, ['Edit File', 'Erase Mark', 'Erase Matrix Signature', 'Format Device', 'Matrix Perception', 'Matrix Search', 'Reboot Device', 'Trace Icon']
  skill 'Cybercombat', 'log', yes, ['Devices', 'Grids', 'IC', 'Personas', 'Sprites', null]
  skill 'Cybertechnology', 'log', no, ['Bodyware', 'Cyberlimbs', 'Headware', 'Repair']
  skill 'Demolitions', 'log', yes, ['Commercial Explosives', 'Defusing', 'Improvised Explosives', 'Plastic Explosives']
  skill 'Electronic Warfare', 'log', no, ['Communications', 'Encryption', 'Jamming', 'Sensor Operations']
  skill 'First Aid', 'log', yes, ['Gunshot Wounds', 'Resuscitation', 'Broken Bones', 'Burns', null]
  skill 'Forgery', 'log', yes, ['Counterfeiting', 'Credstick Forgery,False ID', 'Image Doctoring', 'Paper Forgery']
  skill 'Hacking', 'log', yes, ['Devices', 'Files', 'Hosts', 'Personas']
  skill 'Hardware', 'log', no, ['Commlinks', 'Cyberdecks', 'Smartguns', null]
  skill 'Industrial Mechanic', 'log', no, ['Electrical Power Systems', 'Hydraulics', 'HVAC', 'Industrial Robotics', 'Structural', 'Welding']
  skill 'Locksmith', 'agi', no, ['Combination', 'Keypad', 'Maglock', 'Tumbler', 'Voice Recognition', null]
  skill 'Medicine', 'log', no, ['Cosmetic Surgery', 'Extended Care', 'Implant Surgery', 'Magical Health', 'Organ Culture', 'Trauma Surgery']
  skill 'Nautical Mechanic', 'log', no, ['Motorboat', 'Sailboat', 'Ship', 'Submarine']
  skill 'Navigation', 'int', yes, ['Augmented Reality Markers', 'Celestial', 'Compass', 'Maps', 'GPS']
  skill 'Software', 'log', no, ['Databombs', 'Cleaner', 'Editor', 'Static Veil', null]
]
skillCategory 'Vehicle', 'active', [
  skill 'Gunnery', 'agi', yes, ['Artillery', 'Ballistic', 'Energy', 'Guided', 'Missile', 'Rocket']
  skill 'Pilot Aerospace', 'rea', no, ['Deep Space', 'Launch Craft', 'Remote Operation', 'Semibalistic', 'Suborbital']
  skill 'Pilot Aircraft', 'rea', no, ['Fixed-Wing', 'Lighter-Than-Air', 'Remote Operation', 'Rotary Wing', 'Tilt Wing', 'Vectored Thrust']
  skill 'Pilot Walkre', 'rea', no, ['Biped', 'Multiped', 'Quadruped', 'Remote Operation']
  skill 'Pilot Exotic Vehicle', 'rea', no, [], [null]
  skill 'Pilot Ground Craft', 'rea', yes, ['Bike', 'Hovercraft', 'Remote Operation', 'Tracked', 'Wheeled']
  skill 'Pilot Watercraft', 'rea', yes, ['Hydrofoil', 'Motorboat', 'Remote Operation', 'Sail', 'Ship', 'Submarine']
]

skillGroup 'Acting', ['Con', 'Impersonation', 'Performance']
skillGroup 'Athletics', ['Gymnastics', 'Running', 'Swimming']
skillGroup 'Biotech', ['Cybertechnology', 'First Aid', 'Medicine']
skillGroup 'Close Combat', ['Blades', 'Clubs', 'Unarmed Combat']
skillGroup 'Conjuring', ['Banishing', 'Binding', 'Summoning']
skillGroup 'Cracking', ['Cybercombat', 'Electronic Warfare', 'Hacking']
skillGroup 'Electronics', ['Computer', 'Hardware', 'Software']
skillGroup 'Enchanting', ['Alchemy', 'Artificing', 'Disenchanting']
skillGroup 'Engineering', ['Aeronautics Mechanic', 'Automotive Mechanic', 'Industrial Mechanic', 'Nautical Mechanic']
skillGroup 'Firearms', ['Automatics', 'Longarms', 'Pistols']
skillGroup 'Influence', ['Etiquette', 'Leadership', 'Negotiation']
skillGroup 'Outdoors', ['Navigation', 'Survival', 'Tracking']
skillGroup 'Sorcery', ['Counterspelling', 'Ritual Spellcasting', 'Spellcasting']
skillGroup 'Stealth', ['Disguise', 'Palming', 'Sneaking']
skillGroup 'Tasking', ['Compiling', 'Decompiling', 'Registering']

core.creation =
  priority:
    priorities: ['A', 'B', 'C', 'D', 'E']
    aspects: ['metatype', 'attributes', 'magic', 'skills', 'resources']
    magicTypes: ['magician', 'mysticAdept', 'adept', 'aspectedMagician']
    resonanceTypes: ['technomancer']
    magicOrResonanceTypes: ['magician', 'mysticAdept', 'technomancer', 'adept', 'aspectedMagician']
    aspect:
      metatype:
        A: human: 9, elf: 8, dwarf: 7, ork: 7, troll: 5
        B: human: 7, elf: 6, dwarf: 4, ork: 4, troll: 0
        C: human: 5, elf: 3, dwarf: 1, ork: 0
        D: human: 3, elf: 0
        E: human: 1
      attributes:
        A: 24
        B: 20
        C: 16
        D: 14
        E: 12
      magic:
        A:
          magician:
            mag: 6
            magSkill: [5, 5]
            spell: 10
          mysticAdept:
            mag: 6
            magSkill: [5, 5]
            spell: 10
          technomancer:
            res: 6
            resSkill: [5, 5]
            complexForm: 5
        B:
          magician:
            mag: 4
            magSkill: [4, 4]
            spell: 7
          mysticAdept:
            mag: 4
            magSkill: [4, 4]
            spell: 7
          technomancer:
            res: 4
            resSkill: [4, 4]
            complexForm: 2
          adept:
            mag: 6
            activeSkill: [4]
          aspectedMagician:
            mag: 5
            magSkillGroup: [4]
        C:
          magician:
            mag: 3
            magSkill: []
            spell: 5
          mysticAdept:
            mag: 3
            magSkill: []
            spell: 5
          technomancer:
            res: 3
            resSkill: []
            complexForm: 1
          adept:
            mag: 4
            activeSkill: [2]
          aspectedMagician:
            mag: 3
            magSkillGroup: [2]
        D:
          adept:
            mag: 2
            activeSkill: []
          aspectedMagician:
            mag: 2
            magSkillGroup: []
        E: {}
      skills:
        A: skills: 46, skillGroups: 10
        B: skills: 36, skillGroups: 5
        C: skills: 28, skillGroups: 2
        D: skills: 22, skillGroups: 0
        E: skills: 18, skillGroups: 0
      resources:
        A: 450000
        B: 275000
        C: 140000
        D: 50000
        E: 6000

if exports?
  for k,v of core
    exports[k] = v
else
  @core = core
