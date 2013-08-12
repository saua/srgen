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
  pp: 'Power Points'

text.metatype =
  human: 'Human'
  elf: 'Elf'
  dwarf: 'Dwarf'
  ork: 'Ork'
  troll: 'Troll'

text.term =
  rating: 'Rating'
  skill: 'skill'
  skills: 'skills'
  magSkill: 'Magical skill'
  magSkills: 'Magical skills'
  magSkillGroup: 'Magical skill group'
  magSkillGroups: 'Magical skill groups'
  resSkill: 'Resonance skill'
  resSkills: 'Resonance skills'
  activeSkill: 'Active skill'
  activeSkills: 'Active skills'
  attribute: 'attribute'
  attributes: 'attributes'
  spell: 'spell'
  spells: 'spells'
  complexForm: 'complex Form'
  complexForms: 'complex Forms'
  or: 'or'
  adeptPowers: 'Adept Powers'
  magicOrResonanceType:
    magician: 'Magician'
    technomancer: 'Technomancer'
    adept: 'Adept'
    aspectedMagician: 'Aspected Magician'
    mysticAdept: 'Mystic Adept'

text.creation =
  priority:
    priority: 'Priority'
    priorities: 'Priorities'
    points:
      specialAttributes: 'Special Attributes'
      attributes: 'Attributes'
      skills: 'Skills'
      skillGroups: 'Skill Groups'
      karma: 'Karma'
      resources: 'Resources'
    aspect:
      metatype: 'Metatype'
      attributes: 'Attributes'
      magic: 'Magic or Resonance'
      skills: 'Skills'
      resources: 'Resources'

text.ui =
  unnamedCharacter: 'Unnamed Character'
  name: 'Name'
  namePlaceholder: 'Enter a character name'
  metatype: 'Metatype'
  limits: 'Limits'
  value: 'Value'
  magicOrResonanceType: 'Magic or Resonance Type'
  tab:
    characterGeneration: 'Character Generation'
    attributes: 'Attributes'
    magicOrResonance: 'Magic or Resonance'
    magic: 'Magic'
    resonance: 'Resonance'

text.error =
  invalidMagicType: 'This magic type is not valid with the selected magic/resonance priority.'
  invalidResonanceType: 'This resonance type is not valid with the selected magic/resonance priority.'

text.fn =
  smallNum: (n) ->
    switch n
      when 1 then 'one'
      when 2 then 'two'
      else n
  numTerm: (num, term, terms = text.term) ->
    terms[if num == 1 then term else term + 's']

if exports?
  for k,v of text
    exports[k] = v
else
  @text = text
