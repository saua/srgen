text = {}

text.attributes =
  bod: 'Body'
  agi: 'Agility'
  rea: 'Reaction'
  str: 'Strength'
  wil: 'Willpower'
  log: 'Logic'
  int: 'Intelligence'
  cha: 'Charisma'
  ess: 'Essence'
  edg: 'Edge'
  mag: 'Magic'
  res: 'Resonance'

text.metatype =
  human: 'Human'
  elf: 'Elf'
  dwarf: 'Dwarf'
  ork: 'Ork'
  troll: 'Troll'

text.creation =
  aspects:
    metatype: 'Metatype'
    attributes: 'Attributes'
    magicOrResonance: 'Magic or Resonance'
    skills: 'Skills'
    resources: 'Resources'

text.ui =
  unnamedCharacter: 'Unnamed Character'
  name: 'Name'
  namePlaceholder: 'Enter a character name'
  metatype: 'Metatype'

if typeof exports != 'undefined'
  for k,v of text
    exports[k] = v
else
  @text = text
