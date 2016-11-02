class GamesController < ApplicationController
  def index
    @game = Game.new unless @game
    # @board = GamesHelper.process_board(@game.game_board)
  end

  def show
    @game = Game.find(params[:id])
    @board = GamesHelper.process_board(@game.game_board)
  end

  def create
    @game = Game.new
    @game.user = current_user
    @game.difficulty = params[:difficulty]
    @game.save
    redirect_to @game
  end

  def edit
    @game = Game.find(params[:id])
    p @game
    if request.xhr?
        @game.game_board = GamesHelper.plot(params[:player_move], @game.game_board)
        if check_board('x', @game.game_board)
          p "player wins!!!!"
          @game.game_status = "Player Won!"
        end

        dice = generate_rand(@game.difficulty)
        unless empty_tiles(@game.game_board).empty?
          if dice > 5
            @game.game_board = num_away(1, @game.game_board)
          else
            @game.game_board = random_move(@game.game_board)
          end
        end

        if check_board('o', @game.game_board)
          p "computer wins!!!!"
          @game.game_status = "Computer Won!"
        end
        if empty_tiles(@game.game_board).empty? && @game.game_status == "ongoing"
          @game.game_status = "Draw!"
        end
        @game.save
        @board = GamesHelper.process_board(@game.game_board)
        render json: {
          board: @board,
          game_status: @game.game_status
        }
    end
    @board = GamesHelper.process_board(@game.game_board)
  end

end
