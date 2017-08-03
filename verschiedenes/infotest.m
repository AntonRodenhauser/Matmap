function T = infotest

  data=zeros(10000);
  data_info='hello';
  
  save('infotest.mat','data','data_info', '-v6');
  nRuns=20;

  timeit(@use_load_exist_1)
  
  s=tic;
  for p=1:nRuns
      use_load_exist_1;
  end
  s=toc(s)/nRuns
  
  
  timeit(@use_who_isempty)
  
  s=tic;
  for p=1:nRuns
      use_who_isempty;
  end
  s=toc(s)/nRuns
  
  

end

function isThere = use_load_exist_1
  load('infotest.mat');
  isThere = exist('data_info', 'var');
end

function isThere = use_load_exist_2
  load('infotest.mat', 'data_info');
  isThere = exist('data_info', 'var');
end

function isThere = use_matfile
  isThere = isprop(matfile('infotest.mat'), 'data_info');
end

function isThere = use_whos_ismember
  info = whos('-file', 'infotest.mat');
  isThere = ismember('data_info', {info.name});
end

function isThere = use_who_ismember
  variables = who('-file', 'infotest.mat');
  isThere = ismember('data_info', variables);
end

function isThere = use_who_isempty
  isThere = ~isempty(who('-file', 'infotest.mat', 'data_info'));
end