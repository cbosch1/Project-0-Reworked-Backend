package SpellPointTracker;

import SpellPointTracker.controllers.*;
import SpellPointTracker.services.*;
import SpellPointTracker.util.ConnectionUtil;
import io.javalin.Javalin;

public class ServerDriver {
    private static ConnectionUtil connUtil = new ConnectionUtil();
    private static CalculatorService calcService = new CalculatorService();
    private static CasterService casterService = new CasterServicePostgres(connUtil);
    private static PlayerService playerService = new PlayerServicePostgres(connUtil);
    private static SpellService spellService = new SpellServicePostgres(connUtil);
    private static AdminController admin = new AdminController(casterService, playerService, spellService);
    private static SpellPointsController control = new SpellPointsController(casterService, playerService, spellService, calcService);
    private static SpellPointsWebController webControl = new SpellPointsWebController(control);
    private static WebAdminController webAdmin = new WebAdminController(admin);
    
    private static Javalin app;
    private static final String GAME_PATH = "/game-management/user";
    private static final String PLAYER_PATH = "/data-management/player";
    private static final String CASTER_PATH = "/data-management/caster";
    private static final String SPELL_PATH = "/data-management/spell";
    
    public static void main(String[] args) {
            app = Javalin.create().start(8113);
            //Testing Jenkins Again

            app.get(GAME_PATH + "/login", ctx -> webControl.promptLogin(ctx));
            app.post(GAME_PATH + "/create", ctx -> webControl.promptUserCreate(ctx));
            app.get(GAME_PATH + "/spells/available", ctx -> webControl.getSpells(ctx));
            app.post(GAME_PATH + "/spell/cast/:spell", ctx -> webControl.castSpell(ctx));
            app.post(GAME_PATH + "/rest", ctx -> webControl.rest(ctx));
            app.get(GAME_PATH + "/status", ctx -> webControl.getStatus(ctx));

            app.get(PLAYER_PATH + "s", ctx -> webAdmin.getPlayers(ctx));
            app.get(PLAYER_PATH + "/:id", ctx -> webAdmin.getPlayer(ctx));
            app.put(PLAYER_PATH + "/:id", ctx -> webControl.updatePlayer(ctx));
            app.post(PLAYER_PATH + "/:id", ctx -> webAdmin.createPlayer(ctx));
            app.delete(PLAYER_PATH + "/:id", ctx -> webControl.deletePlayer(ctx));

            app.get(CASTER_PATH + "s", ctx -> webControl.getAllCasters(ctx));
            app.get(CASTER_PATH + "/:id", ctx -> webControl.getCaster(ctx));
            app.put(CASTER_PATH + "/:id", ctx -> webAdmin.updateCaster(ctx));
            app.post(CASTER_PATH + "/:id", ctx -> webAdmin.postCaster(ctx));
            app.delete(CASTER_PATH + "/:id", ctx -> webAdmin.deleteCaster(ctx));

            app.get(SPELL_PATH + "s", ctx -> webAdmin.getSpells(ctx));
            app.get(SPELL_PATH + "/:name", ctx -> webControl.getSpell(ctx));
            app.put(SPELL_PATH + "/:id", ctx -> webAdmin.updateSpell(ctx));
            app.post(SPELL_PATH, ctx -> webAdmin.postSpell(ctx));
            app.delete(SPELL_PATH + "/:id", ctx -> webAdmin.deleteSpell(ctx));
    }
}
