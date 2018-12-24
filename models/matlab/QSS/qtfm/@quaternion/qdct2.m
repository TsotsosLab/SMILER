function Y = qdct2(X, A, L)
  % QDCT2 calcultes the Quaternion DCT (see qfft2)
  %
  % @author: B. Schauerte
  % @date: 2011
  
  if nargin < 2, A = dft_axis(isreal(X)); end
  if nargin < 3, L = 'L'; end
  
  assert(isreal(X)); % don't want to implement the stuff for complex X
  
  %error(nargchk(3, 3, nargin)), error(nargoutchk(0, 1, nargout))

  if ~isscalar(A)
      error('The transform axis cannot be a matrix or vector.');
  end

  if ~isa(A, 'quaternion') || ~isempty(A.w)
      error('The transform axis must be a pure quaternion.')
  end

  if L ~= 'L' && L ~= 'R'
      error('L must have the value ''L'' or ''R''.');
  end

  S = 1;
  if L == 'R'
      S = -1;  % S is a sign bit used (in effect) to conjugate one of the complex
               % components below when the exponential is on the right.  In fact,
               % instead of conjugating the exponential (which would require an
               % inverse fft (ifft), we conjugate the complex component before and 
               % after the transformation. This achieves the same effect because
               % the inverse transform may always be computed by taking the
               % conjugate before and after the transformation (this is a
               % standard DFT trick).
  end

  A = unit(A); % Ensure that A is a unit (pure) quaternion.
  B = orthonormal_basis(A);

  X = change_basis(X, B);

  if isreal(X)
    % Compute the two complex FFTs using the standard Matlab complex FFT
    % function.

    C1 = dct2(complex(scalar(X),      x(X)));
    C2 = dct2(complex(     y(X), S .* z(X)));

    % Compose a real quaternion result from the two complex results.

    Y = quaternion(real(C1), imag(C1), real(C2), S .* imag(C2));
  else
    error('qdct2 is not implemented for complex X')
  end
  
  Y = change_basis(Y, B.'); % Change back to the original basis.