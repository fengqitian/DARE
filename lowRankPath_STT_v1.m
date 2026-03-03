function saliencyMap = lowRankPath_STT_v1(frameBuffer, params)
    
    [H, W, N] = size(frameBuffer);
    
    
    D_raw = double(frameBuffer);
    D = D_raw / 255.0; 

    
    lambda = params.lambda / sqrt(H * N);
    tol = params.tolerance;
    max_iter = params.maxIter;
    rho = 1.5;
    mu = 1.25 / norm(D(:), 2); 
    
    
    B = zeros(H, W, N); % 背景张量 (Low-rank)
    T = zeros(H, W, N); % 目标张量 (Sparse)
    Y = zeros(H, W, N); % 拉格朗日乘子
    
    fprintf('Starting Tensor-ADMM (STT Path)...\n');
    
    for iter = 1:max_iter
        B_prev = B;
        T_prev = T;

        
        temp_B = D - T + (1/mu) * Y;
        B = prox_tnn(temp_B, 1/mu); 
        
        
        temp_T = D - B + (1/mu) * Y;
        T = prox_l1(temp_T, lambda/mu); 
        
        
        Y = Y + mu * (D - B - T);
        
        
        mu = min(rho * mu, 1e10);
        
        
        stop_crit = norm(D(:) - B(:) - T(:), 2) / norm(D(:), 2);
        
        if mod(iter, 20) == 0 || iter == 1
            fprintf('Iter %d/%d, StopCrit: %.4e, mu: %.2f\n', iter, max_iter, stop_crit, mu);
        end

        if stop_crit < tol
            break;
        end
    end
    
    fprintf('Tensor-ADMM converged in %d iterations with error %.4e\n', iter, stop_crit);

 
    saliencyMap_vec = T(:,:,end); 
    
   
    saliencyMap = reshape(saliencyMap_vec, H, W) * 255.0; 
    saliencyMap = abs(saliencyMap);
    
    
    saliencyMap = mat2gray(saliencyMap);
end


function X_shrunk = prox_tnn(X, tau)
    
    [n1, n2, n3] = size(X);
    
    
    X_fft = fft(X, [], 3);
    
    X_shrunk_fft = zeros(n1, n2, n3);
    
    
    for i = 1:n3
        [U, S, V] = svd(X_fft(:,:,i), 'econ');
        
        
        S_shrunk = max(S - tau, 0); 
        
        
        X_shrunk_fft(:,:,i) = U * S_shrunk * V';
    end
    
    
    X_shrunk = ifft(X_shrunk_fft, [], 3, 'symmetric');
end


function T_shrunk = prox_l1(T, lambda)
    T_shrunk = sign(T) .* max(abs(T) - lambda, 0);
end