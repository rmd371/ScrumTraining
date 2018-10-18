describe("shield", function() {
    let subsystem;
    // let ship;

    beforeEach(() => {
        subsystem = new Subsystem();
        // ship = new Ship();
        // shield = new Shield(ship);
        // spyOn(ship, "damageRandomSystem");
    });

    it ('rest and repair completly', function() {
        // given
        subsystem.damage(10);
        // subsystem
        // when
        subsystem.restAndRepair(10)
        // then
        expect(subsystem.damaged).toBe(false);
    });

    it ('cannot be over repaired', function() {
        // given
        subsystem.damage(10);
        // subsystem
        // when
        subsystem.restAndRepair(11)
        // then
        expect(subsystem.damageTakenInDays).toBe(0);
    });

});
