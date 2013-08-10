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

core.creation =
  priority:
    priorities: ['A', 'B', 'C', 'D', 'E']
    aspects: ['metatype', 'attributes', 'magic', 'skills', 'resources']
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
          technomancer:
            res: 6
            resSkill: [5, 5]
            complexForm: 5
        B:
          magician:
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
