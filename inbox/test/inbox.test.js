const assert = require('assert')
const ganache = require('ganache-cli')
const Web3 = require('web3');
const web3 = new Web3(ganache.provider())


class Car {
    park() {
        return 'stopped'
    }

    drive() {
        return 'vrum'
    }
}

describe('Car class', function() {
    it('can park', function() {
        const car = new Car()
        assert.equal(car.park(), 'stopped')
    })

    it('can drive', function() {
        const car = new Car()
        assert.equal(car.drive(), 'vrum')
    })
})