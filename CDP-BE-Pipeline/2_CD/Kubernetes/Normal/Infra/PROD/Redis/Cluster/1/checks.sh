kubectl -n redis logs redis-0
kubectl -n redis describe pod redis-0
kubectl -n redis exec -it redis-0 -- sh
redis-cli 
auth a-very-complex-password-here
info replication
kubectl -n redis exec -it redis-1 -- sh
redis-cli 
auth a-very-complex-password-here
info replication
kubectl -n redis exec -it redis-0 -- sh
SET emp1 raja
SET emp2 mano
SET emp3 ram
