using DifferentialEquations
using Plots
using HTTP
using JSON3

# Fetches population data from a public REST API
function get_population_data(country::String)
    try
        url = "https://restcountries.com/v3.1/name/$(country)"
        response = HTTP.get(url)
        data = JSON3.read(String(response.body))
        return data[1]["population"]
    catch e
        @warn "Could not fetch data for $country. Using fallback value."
        return 83_000_000 # Fallback to Germany's population
    end
end

# SIRD model with financial impact tracking
# u[1]=S, u[2]=I, u[3]=R, u[4]=D, u[5]=C (Cumulative Cost)
function sird_cost_model!(du, u, p, t)
    S, I, R, D, C = u
    N = S + I + R # Current living population
    β, γ, μ, Δ, daily_cost, death_payout = p
    
    # Differential Equations
    du[1] = Δ * N - β * S * I / N           # dS: Births minus new infections
    du[2] = β * S * I / N - (γ + μ) * I    # dI: New infections minus recovery/death
    du[3] = γ * I                          # dR: Recovered
    du[4] = μ * I                          # dD: Deceased
    
    # Financial Impact: Daily treatment cost + lump sum payout for insurance claims
    # Note: We multiply by N_Total in the plot, so we track per-capita cost here
    du[5] = (I * daily_cost) + (du[4] * death_payout)
end

# --- Setup & Parameters ---
country = "USA"
N_Total = get_population_data(country)
initial_infected = 1000

# Initial conditions (scaled to 1.0 for numerical stability)
i0 = initial_infected / N_Total
u0 = [1.0 - i0, i0, 0.0, 0.0, 0.0] 

# Parameters (beta, gamma, mu, delta, cost_per_day, death_benefit)
p = (
    0.35,   # Infection rate
    0.1,    # Recovery rate
    0.01,   # Death rate
    0.0001, # Birth rate
    500.0,  # Cost per day per infected person
    50000.0 # Death benefit payout
)
tspan = (0.0, 180.0)

# Define and solve the ODE
prob = ODEProblem(sird_cost_model!, u0, tspan, p)
sol = solve(prob)

# --- Visualization ---

# 1. Main Pandemic Plot
p1 = plot(sol.t, [u[1]*N_Total for u in sol.u], label="Susceptible", color=:blue)
plot!(sol.t, [u[2]*N_Total for u in sol.u], label="Infected", color=:red)
plot!(sol.t, [u[3]*N_Total for u in sol.u], label="Recovered", color=:green)
plot!(sol.t, [u[4]*N_Total for u in sol.u], label="Deceased", color=:black)
plot!(title="SIRD Simulation: $(country)", ylabel="People", xlabel="Days", legend=:right)

# 2. Cumulative Insurance/Healthcare Costs
p2 = plot(sol.t, [u[5]*N_Total for u in sol.u], 
          label="Total Financial Impact", color=:orange, lw=2,
          title="Economic Cost over Time", ylabel="Euro (€)", xlabel="Days")

# Combine both plots into one layout
plot(p1, p2, layout=(2,1), size=(800, 800))