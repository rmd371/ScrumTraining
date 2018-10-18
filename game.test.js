describe("game", function() {
    let game;
    let ship;


    beforeEach(() => {
        ship = new Ship();
        game = new Game(ship);
        spyOn(ship, "restAndRepair");
    });

    it ('game time increments', function() {
        // given
        // game

        // when time is consumed
        game.timePassed(10);
        // then
        expect(ship.restAndRepair).toHaveBeenCalled();
    });

});
