function obj = simulate_bothalf_bar()
    %sim bottom half
    n=100;
    t=300;
    halfrand= @() 50* rand(t,5);
    w=rand(5,1);
    weights= @()  [w(1)/sum(w) w(2)/sum(w) w(3)/sum(w) w(4)/sum(w) w(5)/sum(w)];
    for i=1:n
        sub(i).bars= halfrand();
            for j=1:t
             sub(i).weights(j,:) = weights();
            end
        sub(i).correct_response= sum((sub(i).bars(:,:).*sub(i).weights(:,:))')';
    end
    obj=sub;
end