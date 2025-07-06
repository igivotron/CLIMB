base = 5
delta = 500
K = 100

def probability(u, w):
    """
    u : user rating
    w : Wall rating
    """
    return pow(base, u/delta) / (pow(base, u/delta) + pow(base, w/delta))

def update_rating(user_rating, wall_rating, result):
    p = probability(user_rating, wall_rating)
    print(p)
    return user_rating + K * (result - p)
