class MovieData
    attr_reader :training_set
    attr_reader :test_set
    #1st initialize reads in u.data's 100k lines
    def initialize(*args)
        if args.size == 1
            file_name = args[0] + "/u.data"
            file_contents = open(file_name)
            user_ratings = make_2d_array()
            @training_set = fill_2d_array(file_contents,user_ratings)
            @test_set = []
        else
            training_set_name = args[0] + "/" + args[1] + ".base"
            test_set_name = args[0] + "/" + args[1] + ".test"
            training_data = open(training_set_name)
            training_ratings = make_2d_array()
            @test_set = open(test_set_name)
            @training_set = fill_2d_array(training_data,training_ratings)
       end
    end    
    #make_2d_array makes a 2d array to hold data about users
    #and movie ratings
    def make_2d_array()
        #initialize a 2d array where every row number is user_id -1 
        #and every column is movie_id-1
        user_ratings = Array.new(943){Array.new(1682)}
        (0..942).each do |i|
            (0..1681).each do |j|
                user_ratings[i][j] = 0.0
            end
        end
        return user_ratings
    end
    #fill 2d array with users and movie ratings where row is user_id - 1 
    #and column is movie_id - 1
    def fill_2d_array(file_contents,user_ratings)
        file_contents.each_line do |line|
            info = line.split(' ')
            user = info[0].to_i
            movie = info[1].to_i
            rating = info[2].to_i
            user_ratings[user - 1][movie -1] = rating
        end
        return user_ratings
    end
   #rating returns rating that user u gave movie m in training set
   def rating(u,m)
        #at row u-1, col m-1 is u's rating of movie m
        u_rating_m = training_set[u-1][m-1]
        return u_rating_m
   end
   #movies returns array of movies u has watched
   def movies(u)
        #init empty array that will hold movies u has seen
        movies_seen_by_u = []
        (0..1681).each do |i|
            rating = training_set[u-1][i]
            if rating != 0.0  #if movie has a rating push it on array
                movie_id = i + 1
                movies_seen_by_u.push(movie_id)
            end
        end
        return movies_seen_by_u
   end 
   #viewers returns array of users who saw movie m
   def viewers(m)
        #init empty array that will hold users who've seen m
        users_who_saw_m = []
        (0..942).each do |i|
            #check what rating each user gave m
            rating = training_set[i][m-1] 
            if rating != 0.0 #then user must've seen m
                user_id = i + 1
                users_who_saw_m.push(user_id)
            end
        end
        return users_who_saw_m
   end 
   #determines popularity of a given movie: the mean of all ratings
   def popularity(movie_id)
        sum_ratings = 0.0
        num_ratings = 0.0
        (0..942).each do |i|
            rating = training_set[i][movie_id-1]
            if rating > 0.0 #meaning there is a rating from user i
                sum_ratings += rating
                num_ratings += 1
            end
        end
        return(mean(sum_ratings, num_ratings))
   end
   #generate an array containing popularity of every movie where index
   #in the array is movie_id-1
   def movie_popularity_array()
        movie_pops = Array.new(1682)
        #go through training_set and calc popularity of each movie and 
        #put popularity in proper index of movie_pops
        (0..1681).each do |movie|
            movie_popularity = popularity(movie + 1)
            movie_pops[movie] = movie_popularity
        end
        return movie_pops
   end
   #Make a popularity list that contains movie_ids in order of most to
   #least popular
   def popularity_list()
        pop_list = []
        movie_id = 0
        items_in_list = 0
        movie_pops = movie_popularity_array()
        #while loop goes until pop_list has all 1682 movies in it
        while items_in_list < 1682
            best_rating = 0
            (0..1681).each do |i|
                if movie_pops[i] > best_rating
                    movie_id = i + 1 #more pop than prev best
                    best_rating = movie_pops[i]
                end
            end
            movie_pops[movie_id-1] = 0 #don't consider this mov again
            pop_list.push(movie_id)  #add next best rated to pop list
            items_in_list += 1
        end
        return pop_list
   end
   #method to get the mean
   def mean(sum, num)
        mean = sum / num
        return mean
   end 
   #go through rows of user1's and user2's movie ratings, and make a new 
   #array of diff's btwn their ratings if they both rated the movie
   def array_comparing_user_ratings(user1, user2)
        diff_btwn_ratings = [] #will store diff's in users' ratings  
        #go thru training_set and compare user1's row with user2's, if
        #both rated a movie, push diff into diff_btwn_ratings
        (0..1681).each do |i|
            rating1 = training_set[user1-1][i]
            rating2 = training_set[user2-1][i]
            if rating1 > 0.0 && rating2 > 0.0 #both rated movie at i
                if rating1 == rating2
                    diff = 0.0
                elsif rating1 > rating2
                    diff = rating1 - rating2
                else 
                    diff = rating2 - rating1
                end
                diff_btwn_ratings.push(diff)
            end
        end
        return diff_btwn_ratings
   end
   #determine mean of diffs btwn 2 u
   def similarity(user1, user2)
        diff_btwn_ratings = array_comparing_user_ratings(user1, user2)
        if diff_btwn_ratings.size > 0 #at least one movie in common
            sum_of_diffs  = 0.0
            mean_diff = 0.0
            (0..diff_btwn_ratings.size-1).each do |i|
                sum_of_diffs += diff_btwn_ratings[i]
            end
            mean_diff = sum_of_diffs / diff_btwn_ratings.size
            #4.0 is most different, 0 is if they gave all the same ratings
            sim = 4.0 - mean_diff
            return sim
        else #users didn't rate any of the same movies
            return -1 #similarity couldn't be evaluated
        end
    end
    #compare all users to u and put similarties in an array
    def comparing_all_to_u(u)
        #make an array that will hold how similar ea user is to u
        user_sims = Array.new(943)
        #now calc each user's sim to u and put val in index 
        #corresponding to the user_id
        (0..942).each do |i|
            user_sims[i] = similarity(u, i+1)
        end
        return user_sims
    end
    #generate a list of most to least similar other users to u
    def most_similar(u)
        user_sims = comparing_all_to_u(u)
        #make new list to push most to least sim users to u
        sim_list = []
        all_null = false #as long as users left who aren't -1 still
        user = 0
        #also, set user u to -1 so not comparing u to itself!
        user_sims[u-1] = -1
        while all_null == false
            most_sim = -1
            (0..942).each do |i|
                if user_sims[i] > most_sim
                    most_sim = user_sims[i]
                    user = i + 1
                end
            end
            if most_sim == -1 #no more users who reviewed same movs as u
                all_null = true
            else
                user_sims[user-1] = -1 #user added, don't consider again
                sim_list.push(user)
            end
        end
        return sim_list
    end 
    #make prediction of u's rating of m based on top ten most similar users to 
    #u who also rated m
    def predict(u,m)  
        most_sim = most_similar(u)
        m_ratings_sum = 0.0
        m_ratings_count = 0.0
        (0..most_sim.size-1).each do |i|
            user = most_sim[i] #next most similar user to u
            m_rating = rating(user, m) #check user's rating of m
            if m_rating > 0.0 #if user rated m
                m_ratings_sum += m_rating
                m_ratings_count += 1
            end
            if m_ratings_count >= 10  #just consider 10 most sim to u 
                break
            end
        end
        prediction = mean(m_ratings_sum, m_ratings_count)
        return prediction
    end      
    #run test runs predict of first k ratings in test results
    def run_test(k)
        #results holds user, movie, actual rating, and predicted rating
        results = Array.new(k){Array.new(4)}        
        (0..k-1).each do |i|
            line = test_set.readline
            info = line.split(' ')
            user = info[0].to_i
            movie = info[1].to_i
            results[i][0] = user #user
            results[i][1] = movie #movie
            results[i][2] = info[2].to_i #actual rating
            results[i][3] = predict(user, movie) #predicted rating
        end
        test_set.seek(0)  #rewind test_set
        test = MovieTest.new(results)
        return test
    end                          
end

class MovieTest
    attr_reader :prediction_results
    def initialize(results)
        @prediction_results = results
    end
    #calculate the mean prediction error
    def mean()
        errors_sum = 0.0
        #add all the errors between actual and predicted rating, then divide by
        #number of predictions made
        (0..prediction_results.size - 1).each do |i|
            actual_rating = prediction_results[i][2] 
            prediction = prediction_results[i][3]
            if actual_rating > prediction
                errors_sum += actual_rating - prediction
            end
            if prediction > actual_rating
                errors_sum += prediction - actual_rating
            end
        end
        mean_prediction_error = errors_sum / prediction_results.size
        return mean_prediction_error
    end
    #return standard deviation of the errors
    def stddev()
        #make a list of the differences between actual and predicted ratings
        number_of_values = prediction_results.size
        values = Array.new(number_of_values)
        #now fill the list with the differences
        (0..number_of_values-1).each do |i|
            actual = prediction_results[i][2]
            prediction = prediction_results[i][3]
            if actual > prediction
                values[i] = actual - prediction
            end
            if prediction > actual
                values[i] = prediction - actual
            end
        end
        #now do cumulative sum of (ea. value - mean)^2
        sum = 0.0
        mean_error = mean()
        (0..number_of_values-1).each do |i|
            diff = values[i] - mean_error
            sum += diff * diff
        end
        #now mult. sum by 1/number_of_values
        answer = 0.0
        answer = sum * (1.0 / number_of_values)
        #standard deviation will be sqrt of answer
        standard_deviation = Math.sqrt(answer)
        return standard_deviation         
    end
    #return root mean square error of predictions
    def rms()
        number_of_values = prediction_results.size
        values = Array.new(number_of_values)
        (0..number_of_values-1).each do |i|
            values[i] = (prediction_results[i][2]-prediction_results[i][3])
            values[i] *= values[i] #square diffs
        end
        sum_of_diffs = 0.0
        (0..number_of_values-1).each do |i|
            sum_of_diffs += values[i]
        end
        mean = sum_of_diffs / number_of_values #get mean of diffs
        rms = Math.sqrt(mean) #take sqrt of mean for rms
        return rms         
    end
    #return 2d array of predictions in form of [user,movie,rating,prediction]
    def to_a()
        #prediction_results is a 2d array with info about u,m,r,p in each row
        return prediction_results
    end
end

    
mov = MovieData.new("ml-100k","u1")
test = mov.run_test(10)
results = test.to_a()
(0..9).each do |i|
    print "User: #{results[i][0]}, Movie: #{results[i][1]}, Rating: #{results[i][2]}, "
    print "Prediction: #{results[i][3]}"
    puts "\n"
end
mean_prediction_error = test.mean()
puts "mean prediction error is #{mean_prediction_error}"
std_dev = test.stddev()
puts "standard deviation is #{std_dev}"
rms = test.rms()
puts "root mean square error is #{rms}"





    

