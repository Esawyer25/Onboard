require "securerandom"

class WelcomeController < ApplicationController
  @@location = "LDE2BCC3M9ZJW"

  def index
    @team_members = get_team_members
    @day = Date.today
    puts @day
  end

  def search_locations
    locations = get_locations
    unless locations
      flash[:alert] = "Locations not found"
      return render action: :index
    end
  end

  #todo: support select enviroment
  def get_client
    token = Rails.application.credentials[:production][:square][:square_access_token]
    client = Square::Client.new(
      access_token: token,
      environment: "production",
    )
    return client
  end

  def get_locations
    result = get_client.locations.list_locations
    if result.success?
      return result.data
    elsif result.error?
      warn result.errors
    end
  end

  def get_team_members
    result = get_client.team.search_team_members(
      body: {},
    )

    if result.success?
      return filter_team_members(result.data[:team_members])
    elsif result.error?
      warn result.errors
    end
  end

  def filter_team_members(team_members)
    team = []
    for index in (0...team_members.length)
      unless team_members[index][:is_owner]
        person = {}
        person[:given_name] = team_members[index][:given_name]
        person[:family_name] = team_members[index][:family_name]
        person[:id] = team_members[index][:id]
        team.push(person)
      end
    end
    return team
  end

  def add_team_member
    result = get_locations.team.create_team_member(
      body: {
        team_member: {
          status: "ACTIVE",
          given_name: params[:family_name],
          family_name: params[:given_name],
        },
      },
    )

    if result.success?
      return result.data
    elsif result.error?
      warn result.errors
    end
  end

  def update_shift
    puts "*********"
    member_id = params[:member_id]
    puts "*********"
    puts member_id

    open_shift = get_open_shift(member_id)
    if (open_shift)
      puts open_shift
      end_shift(member_id, open_shift)
    else
      puts "there is not an open shift"
    end
  end

  def end_shift(member_id, open_shift)
    puts "in end shift"
    # puts open_shift
    # puts open_shift[0]
    # puts open_shift[0][0]
    shift_id = open_shift[0][0][:id]
    start_time = open_shift[0][0][:start_at]
    end_time = Time.now.to_datetime.rfc3339
    result = get_client.labor.update_shift(
      id: "ZJ62C5A2DA93F",
      body: {
        shift: {
          id: "what am I?",
          location_id: "LBX98ER83QPCT",
          start_at: start_time,
          end_at: end_time,
          # wage: {
          #   hourly_rate: {
          #     amount: 0,
          #     currency: "CAD"
          #   }
          # },
          team_member_id: member_id,
        },
      },
    )

    if result.success?
      puts "success!!!!"
      puts result.data
    elsif result.error?
      warn result.errors
    end
  end

  def schedule_shift
    puts "in scheduleing"
    # result = get_client.labor.create_shift(
    #   body: {
    #     idempotency_key: SecureRandom.uuid,
    #     shift: {
    #       location_id: @@location,
    #       start_at: "2021-03-07T05:00:00-08:00",
    #       end_at: "2021-03-07T07:00:00-08:00",
    #       team_member_id: "TMRo-VjomI0NJlYy"
    #     }
    #   }
    # )

    # if result.success?
    #   puts "scheduled shift"
    #   puts result.data
    # elsif result.error?
    #   puts "DID NOT scheduled shift"
    #   warn result.errors
    # end
  end

  def start_shift
    datetime = Time.now.to_datetime.rfc3339
    puts "IN STARTED A SHIFT"
    puts datetime
    member_id = params[:member_id]
    result = get_client.labor.create_shift(
      body: {
        idempotency_key: SecureRandom.uuid,
        shift: {
          location_id: @@location,
          start_at: datetime,
          team_member_id: params[:member_id],
        },
      },
    )

    if result.success?
      puts "scheduled shift"
      puts result.data
    elsif result.error?
      puts "DID NOT scheduled shift"
      warn result.errors
    end
  end

  def get_open_shift(member_id)
    result = get_client.labor.search_shifts(
      body: {
        query: {
          filter: {
            location_ids: [
              @@location,
            ],
            status: "OPEN",
            team_member_ids: [
              member_id,
            ],
          },
        },
      },
    )

    if result.success?
      puts "success!"
      puts result.data
      return result.data
    elsif result.error?
      warn result.errors
    end
  end

  def stop_shift
    puts "in shift stopped"
    member_id = params[:member_id]
    open_shift = get_open_shift(member_id)
    if (open_shift)
      shift_id = open_shift[0][0][:id]
      start_at = open_shift[0][0][:start_at]
      close_shift(member_id, shift_id, start_at)
    else
      puts "there is not an open shift"
    end

    render :json => { "response" => "OK" }
  end

  def close_shift(member_id, shift_id, start_at)
    puts "in close shift"
    result = get_client.labor.update_shift(
      id: shift_id,
      body: {
        shift: {
          location_id: "LDE2BCC3M9ZJW",
          start_at: start_at,
          end_at: Time.now.to_datetime.rfc3339,
          wage: {
            hourly_rate: {
              amount: 0,
              currency: "CAD",
            },
          },
          team_member_id: member_id,
        },
      },
    )
    puts result
    if result.success?
      puts "shift closed"
      puts result.data
    elsif result.error?
      puts "error with shift close"
      warn result.errors
    end
  end

  def get_open_shift(member_id)
    result = get_client.labor.search_shifts(
      body: {
        query: {
          filter: {
            location_ids: [],
            status: "OPEN",
            team_member_ids: [member_id],
          },
          sort: {
            order: "ASC",
          },
        },
      },
    )

    if result.success?
      return result.data
    elsif result.error?
      warn result.errors
    end
  end

  def start_break
    puts "in start break"
    member_id = params[:member_id]
    open_shift = get_open_shift(member_id)
    if (open_shift)
      shift_id = open_shift[0][0][:id]
      start_at = open_shift[0][0][:start_at]
      send_break_start(member_id, shift_id, start_at)
    else
      puts "there is not an open shift"
    end

    render :json => { "response" => "OK" }
  end

  def end_break
    puts "in end break"
    member_id = params[:member_id]
    open_shift = get_open_shift(member_id)
    if (open_shift)
      shift_id = open_shift[0][0][:id]
      shift_start_at = open_shift[0][0][:start_at]
      puts "where is the break start time?"
      break_start_at = open_shift[0][0][:breaks][0][:start_at]
      send_break_end(member_id, shift_id, shift_start_at, break_start_at)
    else
      puts "there is not an open shift"
    end

    render :json => { "response" => "OK" }
  end

  def send_break_end(member_id, shift_id, shift_start_at, break_start_at)
    puts "in start break"
    result = get_client.labor.update_shift(
      id: shift_id,
      body: {
        shift: {
          location_id: "LDE2BCC3M9ZJW",
          start_at: shift_start_at,
          wage: {
            hourly_rate: {
              amount: 0,
              currency: "CAD",
            },
          },
          breaks: [
            {
              start_at: break_start_at,
              end_at: Time.now.to_datetime.rfc3339,
              break_type_id: "FZXY6TXHGW6TE",
              name: "Lunch",
              expected_duration: "PT45M",
              is_paid: true
            }
          ],
          team_member_id: member_id,
        },
      },
    )
    puts result
    if result.success?
      puts "Lunch Ended "
      puts result.data
    elsif result.error?
      puts "error with lunch ended"
      warn result.errors
    end
  end

  def send_break_start(member_id, shift_id, start_at)
    puts "in start break"
    result = get_client.labor.update_shift(
      id: shift_id,
      body: {
        shift: {
          location_id: "LDE2BCC3M9ZJW",
          start_at: start_at,
          wage: {
            hourly_rate: {
              amount: 0,
              currency: "CAD",
            },
          },
          breaks: [
            {
              start_at: Time.now.to_datetime.rfc3339,
              break_type_id: "FZXY6TXHGW6TE",
              name: "Lunch",
              expected_duration: "PT45M",
              is_paid: true
            }
          ],
          team_member_id: member_id,
        },
      },
    )
    puts result
    if result.success?
      puts "Lunch started"
      puts result.data
    elsif result.error?
      puts "error with lunch started"
      warn result.errors
    end
  end
end
