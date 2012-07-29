bt = require '../../src/common/basetypes'

describe 'Base Types', ->
    
    describe 'Calculated Value', ->

    	cv = undefined

    	beforeEach ->
   			cv = new bt.CalculatedValue

    	it 'is undefined when having no effect', ->
    		expect(cv.value()).toBeUndefined()

    	it 'throws when adding null effect', ->
    		expect(-> cv.add(null)).toThrow()

    	it 'throws when trying to set the value directly', ->
    		expect(-> cv.set('value', 13)).toThrow()

    	it 'throws when trying to unset the value directly', ->
    		expect(-> cv.unset('value')).toThrow()

    	it 'throw when adding a simple value', ->
    		expect(-> cv.add(1)).toThrow()
    		expect(-> cv.add('effect')).toThrow()

    	it 'throw when adding a function', ->
    		expect(-> cv.add(->)).toThrow()

    	it 'throws when adding a plain effect', ->
    		cv.add new bt.Effect()
    		expect(-> cv.value()).toThrow()

    	describe 'Set Effect', ->
    		it 'has a useful toString', ->
    			expect(new bt.SetEffect(1).toString()).toEqual('=1')

    		it 'returns the value of the set effect', ->
    			cv.add new bt.SetEffect(1)
    			expect(cv.value()).toEqual(1)

    		it 'throws on second set effect', ->
    			cv.add new bt.SetEffect(1)
    			cv.add new bt.SetEffect(2)
    			expect(-> cv.value()).toThrow()

    		it 'throws on second set effect when first value is false-y', ->
    			cv.add new bt.SetEffect(false)
    			cv.add new bt.SetEffect('value')
    			expect(-> cv.value()).toThrow()

    	describe 'Add Effect', ->

    		it 'has a useful toString', ->
    			expect(new bt.AddEffect(0).toString()).toEqual('±0')
    			expect(new bt.AddEffect(1).toString()).toEqual('+1')
    			expect(new bt.AddEffect(-1).toString()).toEqual('-1')

    		it 'throws when added as the only effect', ->
    			cv.add new bt.AddEffect(1)
    			expect(-> cv.value()).toThrow()

    		it 'adds the value when added to a set effect', ->
    			cv.add new bt.SetEffect(1)
    			cv.add new bt.AddEffect(2)
    			expect(cv.value()).toEqual(3)

    		it 'works twice', ->
    			cv.add new bt.SetEffect(1)
    			cv.add new bt.AddEffect(2)
    			cv.add new bt.AddEffect(3)
    			expect(cv.value()).toEqual(6)

    		it 'handles adding an add effect after calculating the value', ->
    			cv.add new bt.SetEffect(1)
    			cv.value()
    			cv.add new bt.AddEffect(2)
    			expect(cv.value()).toEqual(3)